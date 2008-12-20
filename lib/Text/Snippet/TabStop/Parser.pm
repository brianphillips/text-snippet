package Text::Snippet::TabStop::Parser;

use strict;
use warnings;
use List::Util qw(first);
use Class::MOP;
use Carp qw(croak);

my @types = map { "Text::Snippet::TabStop::$_" } qw( Basic WithDefault WithTransformer );
Class::MOP::load_class($_) for(@types);

sub parse {
    my $class = shift;
    my $src = shift;
	my $parsed = first { $_->parse($src) } @types;
	return $parsed or croak "unable to find parser for tab stop source: [$src]";
}

1;
