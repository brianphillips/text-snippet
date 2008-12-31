package Text::Snippet::TabStop::Basic;

use strict;
use warnings;

use base qw(Text::Snippet::TabStop);

=head1 NAME

Text::Snippet::TabStop::Basic - Basic TabStop

=head1 SYNOPSIS

This class provides basic tab stop functionality and inherits from
L<Text::Snippet::TabStop>.

=head1 CLASS METHODS

=head2 parse

The main entry point into this class.  It takes a single argument which
consists of the source of the tab stop within the snippet.

=cut

sub parse {
	my $class = shift;
	my $src = shift;
	if($src =~ m/^\$(\d+)$/ || $src =~ m/^\$\{(\d+)\}$/){
		return $class->_new( index => $1, src => $src );
	}
	return;
}

1;
