use strict;
use warnings;
use Test::More;

my @tests = map {
	[ map { chomp; $_ } split( /\n====\n/, $_ ) ]
} split( /\n--------\n/, join( '', grep {!/^#/} <DATA> ) );

plan(tests => @tests + 16);
use_ok('Text::Snippet::TabStop::Cursor');
use_ok('Text::Snippet');

foreach my $t(@tests){
	my $s = Text::Snippet->parse($t->[0]);
	my $c = $s->cursor;
	my @values = split(/\|/, $t->[1]);
	while(@values && $c->has_next){
		$c->next->replace(shift(@values));
	}
	is($s->to_string, $t->[2], "parsed $t->[0] correctly");
}

my $s = Text::Snippet->parse('$1 and $2 and $3! Oh my!');
my $c = $s->cursor;
is_deeply( [ $c->current_regions ], [ ], 'nothing currently selected' );
$c->next;
is_deeply( [ $c->current_regions ], [ [ 0, 0 ] ], 'no replacement current regions' );
$c->current->replace('Lions');
is_deeply( [ $c->current_regions ], [ [ 0, 5 ] ], 'with replacement current regions' );
$c->next->replace('Tigers');
is_deeply( [ $c->current_regions ], [ [ 10, 6 ] ], 'second tab stop current region' );
$c->next->replace('Bears');
is_deeply( [ $c->current_regions ], [ [ 21, 5 ] ], 'third tab stop current region' );
$c->prev->replace('Turtles');
$c->next;
is_deeply( [ $c->current_regions ], [ [ 22, 5 ] ], 'current regions shift with subsequent edits');

$s = Text::Snippet->parse("1. \$1\n2. \$1\$2\n3. \$1\$2\$3");
$c = $s->cursor;
is_deeply($c->current_position, [0,0], 'starts at 0,0');
$c->next;
is_deeply($c->current_position, [3,0], 'first tab-stop at 3,0');
$c->next;
is_deeply($c->current_position, [3,1], 'second tab-stop at 3,1');
$c->next;
is_deeply($c->current_position, [3,2], 'third tab-stop at 3,2');
$c->prev->replace('Foo');
$c->next;
is_deeply($c->current_position, [6,2], 'after modifying $2, third tab-stop at 6,2');
$c->prev; $c->prev->replace('Blah');
$c->next; $c->next;
is_deeply($c->current_position, [10,2], 'after modifying $1 and $2, third tab-stop at 10,2');
$c->prev;
is_deeply($c->current_position, [7,1], 'after modifying $1 and $2, second tab-stop at 7,1');
$c->prev;
is_deeply($c->current_position, [3,0], 'after modifying $1, first tab-stop at 3,0');


__DATA__
Thing ${1} and Thing $2
====
one|two
====
Thing one and Thing two
--------
Thing ${2} and Thing $1
====
one|two
====
Thing two and Thing one
