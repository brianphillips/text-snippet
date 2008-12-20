package Text::Snippet;

use warnings;
use strict;
use Text::Balanced qw(extract_bracketed extract_multiple);
use Text::Snippet::TabStop::Parser;

=head1 NAME

Text::Snippet - TextMate-like snippet functionality

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module provides TextMate-like snippet functionality in an
editor-agnostic API.  The snippet syntax is modeled after the
snippets provided by TextMate.

    use Text::Snippet;

    my $snippet = Text::Snippet->parse($snippet_content);

=head1 SUPPORTED SNIPPET SYNTAX

=over 4

=item * Plain text

The simplest snippet is just plain text with no tab stops and is returned
verbatim to the caller.

=item * Simple tab stops

Tab stops are indications for where the cursor should be placed after
the user inserts a snippet.  Simple tab stops are simply a dollar sign
followed by a digit.  The special C<$0> tab stop is terminal and is where
the cursor will end up when the user has progressed through all other
tab stops defined by the snippet.  If no C<$0> tab stop is indicated,
one is added by default right after the final character of the snippet.
A simple "if" snippet (two explicit tab stops plus an implicit terminal
after the closing brace of the C<if> block):

	if ($1) {
		$2
	}

=item * Tab stops with defaults

Sometimes a snippet may provide a default value to the user to make the
snippet easier to flesh out.  These types of tab stops look like so:

	while( my(\$${1:key}, \$${2:value}) = each(%${3:hash}) {
		$0
	}

While navigating through the tab stops, the first three positions
will provide default values ("key", "value" and "hash" respectively).
The terminal tab stop will leave the cursor in the body of the C<while>
block.

=item * Tab stops with mirroring

Sometimes you may want the value the user entered in one tab stop to be
copied to another.  This (in TextMate lingo) is called mirroring.  This is
very simple to do, just use the same index on more than one tab stop and
the content entered in the first will automatically be used in the others.
A rather contrived example:

	foreach my \$${1:item} (@${2:array}) {
		print "$${1}\n";
	}

All occurences of the first tab stop (the loop variable and in the C<print>
statement) will have the same value (defaulting to "item").

=item * Transforming tab stops

The most advanced type of tab stop allows you to modify the entered
value on the fly using a regular expression.  For instance, if you like
to use C<getFoo> and C<setFoo> accessors with Moose, you might use the
following snippet:

	has ${1:propertyName} => (
		is => '${2:rw}',
		isa => '${3:Str}',
		reader => 'get${1/./\u$0/}),
		writer => 'set${1/./\u$0}),
	);

If the user leaves all the defaults, the output of this snippet would be:

	has propertyName => (
		is => 'rw',
		isa => 'Str',
		reader => 'getPropertyName',
		writer => 'setPropertyName'
	);

=back

=head1 CLASS METHODS

=head2 parse

=cut

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(ArrayRef Str);
use overload '""' => \&to_string;

my $list_of_stringables = subtype ArrayRef, where {
	scalar( grep { !ref($_) || overload::Method( $_, q("") ) } @$_ ) == @$;
};
has chunks => (
	is => 'ro',
	isa => $list_of_stringables,
	required => 1,
	auto_deref => 1,
	coerce => 1,
);

has src => (
	is => 'rw',
	isa => Str,
	required => 1,
);

has tab_stops => (
	is => 'rw',
	isa => ArrayRef,
	required => 1,
);

no Moose;

__PACKAGE__->meta->make_immutable;

sub parse {
	my $class  = shift;
	my $source = shift;
	my @raw    = extract_multiple( $source, [ { Simple => qr/\$\d+/ },
			{ Curly  => sub { extract_bracketed( $_[0], '{}', '\$(?=\{\d)' ) } },
			{ Plain  => qr/[^\$]+/ },
	], undef, 1); 

	my $pos = 0;
	my %tab_stop_cache;
	my @chunks;
	foreach my $c (@raw) {
		if ( ref($c) eq 'Plain' ) {
			push( @chunks, $$c );
		} else {

			# the leading $ gets stripped on these by extract_bracketed...
			$$c = '$' . $$c if(ref($c) eq 'Curly');

			my $t = Text::Snippet::TabStop->parse( $$c );

			if ( exists( $tab_stop_cache{ $t->index } ) ) {
				$t->parent($tab_stop_cache{ $t->index });
			} else {
				$tab_stop_cache{ $t->index } = $t;
			}
			push( @chunks, $t );
		}
	}

	my @tab_stops = map { $tab_stop_cache{$_} } sort keys %tab_stop_cache;

	if ( exists( $tab_stop_cache{'0'} ) ) {
		# put the zero-th tab stop on the end of the array
		push( @tab_stops, shift(@tab_stops) );
	} else {
		# append the implicit zero-th tab stop on the end of the array
		my $implicit = Text::Snippet::TabStop::Parser->parse( '$0' );
		push( @tab_stops, $implicit );
		push( @chunks,       $implicit );
	}

	my %params = (
		src          => $source,
		chunks       => \@chunks,
		tab_stops => \@tab_stops,
	);
	return $class->new(%params);

}

=head1 INSTANCE METHODS

=head2 to_string

Obviously, gets the full content of the snippet as it currently exists.
This object is overloaded as well so simply printing the object or
including it inside double quotes will have the same effect.

=cut

sub to_string {
	my $self = shift;
	return join('', $self->chunks);
}


=head1 AUTHOR

Brian Phillips, C<< <bphillips at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-snippet at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Snippet>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Snippet


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Snippet>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Snippet>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Snippet>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Snippet/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Brian Phillips.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Text::Snippet

