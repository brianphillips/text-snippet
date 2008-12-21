package Text::Snippet::TabStop::WithTransformer;

use strict;
use warnings;
use Moose;
use MooseX::Types::Moose qw(Str);

with qw(Text::Snippet::TabStop);
has transformer => (
	is => 'rw',
	isa => Str,
	required => 1,
);

no Moose;

__PACKAGE__->meta->make_immutable;

sub parse {
	my $class = shift;
	my $src = shift;
	if($src =~ m#^\$\{(\d+)/([^/]+?)/([^/]*)/(.*?)\}$#){
		my ($tab_index, $search, $replace) = ($1, $2, $3);
	}
	return;
}

1;
