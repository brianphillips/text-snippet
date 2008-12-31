package Text::Snippet::TabStop::Parser;

use strict;
use warnings;
use List::Util qw(first);
use Carp qw(croak);

my @types = map { "Text::Snippet::TabStop::$_" } qw( Basic WithDefault WithTransformer );
for(@types){
	eval "require $_";
	croak $@ if $@;
}

sub parse {
    my $class = shift;
    my $src = shift;
	foreach my $t(@types){
		my $p = $t->parse($src);
		return $p if defined $p;
	}
	croak "unable to find parser for tab stop source: [$src]";
}

1;
