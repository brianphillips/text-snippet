use strict;
use warnings;
use Test::More tests => 6;

BEGIN { use_ok('Text::Snippet') };

my $snippet = Text::Snippet->parse('Hello $1!');
is($snippet->to_string, "Hello !", "tab stop with no replacement");
my (@ts) = @{$snippet->tab_stops};
$ts[0]->replace("World");
is($snippet->to_string, "Hello World!", "tab stop with replacement");
ok($ts[-1]->is_terminal, 'final tab stop is terminal');

$snippet = Text::Snippet->parse('Hello ${2}!');
ok($snippet, 'parsed simple tab stop with curlies');
(@ts) = @{ $snippet->tab_stops };
$ts[0]->replace("World");
is($snippet->to_string, "Hello World!", "non-1, but first, tab stop with replacement");
