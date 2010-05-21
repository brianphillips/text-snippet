#!perl

use strict;
use warnings;

use Test::More;
use File::Find;
use File::Temp qw{ tempdir };

my @modules;
find(
  sub {
    return if $File::Find::name !~ /\.pm\z/;
    my $found = $File::Find::name;
    $found =~ s{^lib/}{};
    $found =~ s{[/\\]}{::}g;
    $found =~ s/\.pm$//;
    # nothing to skip
    push @modules, $found;
  },
  'lib',
);

my @scripts = glob "bin/*";

plan tests => scalar(@modules) + scalar(@scripts);

{
    # fake home for cpan-testers
    # no fake requested ## local $ENV{HOME} = tempdir( CLEANUP => 1 );

    is( qx{ $^X -Ilib -e "use $_; print '$_ ok'" }, "$_ ok", "$_ loaded ok" )
        for sort @modules;

    SKIP: {
        eval "use Test::Script; 1;";
        skip "Test::Script needed to test script compilation", scalar(@scripts) if $@;
        foreach my $file ( @scripts ) {
            my $script = $file;
            $script =~ s!.*/!!;
            script_compiles_ok( $file, "$script script compiles" );
        }
    }
}
