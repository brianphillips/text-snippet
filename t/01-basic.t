use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok('Text::Snippet') };

can_ok('Text::Snippet', 'parse');

my $snippet = Text::Snippet->parse("Just Checking!");
is($snippet, "Just Checking", "string overloading");
