package Text::Snippet::TabStop::WithDefault;

use strict;
use warnings;
use Moose;
use MooseX::Types::Moose qw(Str);

with qw(Text::Snippet::TabStop);
has default => (
	is => 'rw',
	isa => Str,
	required => 1,
);
has '+replacement' => (
	default => sub { shift->default }
);


no Moose;

__PACKAGE__->meta->make_immutable;

sub parse {
	my $class = shift;
	my $src = shift;
	if($src =~ m/\$\{(\d+):(.*)\}/){
		return $class->new( index => $1, src => $src, default => $2 || '' );
	}
	return;
}

1;
