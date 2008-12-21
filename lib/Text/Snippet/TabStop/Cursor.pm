package Text::Snippet::TabStop::Cursor;

use strict;
use warnings;
use Moose;
use Scalar::Util qw(blessed refaddr);

has snippet => (
	is       => 'ro',
	isa      => 'Text::Snippet',
	required => 1,
);

no Moose;

__PACKAGE__->meta->make_immutable;

sub BUILD {
	my $self = shift;
	$self->{i} = -1;
}

sub has_prev {
	my $self  = shift;
	my @stops = $self->snippet->tab_stops;
	return @stops && $self->{i} > 0;
}

sub prev {
	my $self = shift;
	return $self->has_prev ? $self->snippet->tab_stops->[ --$self->{i} ] : ();
}

sub has_next {
	my $self  = shift;
	my @stops = $self->snippet->tab_stops;
	return @stops && $self->{i} < $#stops;
}

sub next {
	my $self = shift;
	return $self->has_next ? $self->snippet->tab_stops->[ ++$self->{i} ] : ();
}

sub current {
	my $self  = shift;
	return unless($self->{i} >= 0);
	my $stops = $self->snippet->tab_stops;
	if ( exists( $stops->[ $self->{i} ] ) ) {
		return $stops->[ $self->{i} ];
	}
	return;
}

sub current_regions {
	my $self    = shift;
	my $current = $self->current;
	return if ( !defined $current );

	my $pos = 0;
	my @regions;
	foreach my $c ( $self->snippet->chunks ) {
		if ( blessed($c) && ( refaddr($c) == refaddr($current) || ( $c->has_parent && $c->parent == $current ) ) ) {
			push( @regions, [ $pos, length($c) ] );
		}
		$pos += length($c);
	}
	return @regions;
}

1;
