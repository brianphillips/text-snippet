use strict;
use warnings;
use Test::More;

my @tests = map {
	[ map { chomp; $_ } split( /\n====\n/, $_ ) ]
} split( /\n--------\n/, join( '', grep {!/^#/} <DATA> ) );

plan(tests => (@tests * 2) + 10);
use_ok('Text::Snippet::TabStop::Cursor');
use_ok('Text::Snippet');

foreach my $t(@tests){
	my $s = Text::Snippet->parse($t->[0]);
	my $c = $s->cursor;
	my @values = split(/\|/, $t->[1]);
	while($c->has_next){
		my $ts = $c->next;
		$ts->replace(shift(@values)) if(@values);
	}
	is($c->is_terminal, 1, 'is_terminal == true on last tab stop');
	is($s->to_string, $t->[2], "parsed $t->[0] correctly");
}

my $s = Text::Snippet->parse("1. \$1\n2. \$1\$2\n3. \$1\$2\$3");
my $c = $s->cursor;
is_deeply($c->current_position, [0,0], 'starts at 0,0');
$c->next;
is_deeply($c->current_position, [0,3], 'first tab-stop at 0,3');
$c->next;
is_deeply($c->current_position, [1,3], 'second tab-stop at 1,3');
$c->next;
is_deeply($c->current_position, [2,3], 'third tab-stop at 2,3');
$c->prev->replace('Foo');
$c->next;
is_deeply($c->current_position, [2,6], 'after modifying $2, third tab-stop at 2,6');
$c->prev; $c->prev->replace('Blah');
$c->next; $c->next;
is_deeply($c->current_position, [2,10], 'after modifying $1 and $2, third tab-stop at 2,10');
$c->prev;
is_deeply($c->current_position, [1,7], 'after modifying $1 and $2, second tab-stop at 1,7');
$c->prev;
is_deeply($c->current_position, [0,3], 'after modifying $1, first tab-stop at 0,3');


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
