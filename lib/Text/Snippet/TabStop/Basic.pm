package Text::Snippet::TabStop::Basic;

use strict;
use warnings;

use base qw(Text::Snippet::TabStop);

sub parse {
	my $class = shift;
	my $src = shift;
	if($src =~ m/^\$(\d+)$/ || $src =~ m/^\$\{(\d+)\}$/){
		return $class->new( index => $1, src => $src );
	}
	return;
}

1;
