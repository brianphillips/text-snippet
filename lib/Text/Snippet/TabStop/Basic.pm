package Text::Snippet::TabStop::Basic;

use strict;
use warnings;
use overload '""' => sub { shift->to_string };
use Moose;

with qw(Text::Snippet::TabStop);

no Moose;

__PACKAGE__->meta->make_immutable;

sub parse {
	my $class = shift;
	my $src = shift;
	if($src =~ m/\$(\d+)/ || $src =~ m/\$\{(\d+)\}/){
		return $class->new( index => $1, src => $src );
	}
	return;
}

1;
