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

sub _is_current {
	my $self = shift;
	my $current = $self->current;
	my $tab_stop = shift;
	return blessed($tab_stop) && (refaddr($tab_stop) == refaddr($current) || ($tab_stop->has_parent && refaddr($tab_stop->parent) == refaddr($current)));
}

sub current_regions {
	my $self    = shift;
	return if ( !defined $self->current );

	my $pos = 0;
	my @regions;
	foreach my $c ( $self->snippet->chunks ) {
		if ( $self->_is_current( $c ) ){
			push( @regions, [ $pos, length($c->to_string) ] );
		}
		$pos += length(blessed($c) ? $c->to_string : "$c");
	}
	return @regions;
}

sub current_position {
	my $self = shift;
	my $current = $self->current;
	my ($x, $y) = (0,0);
	return [$x,$y] if ! defined $current;
	
	foreach my $c($self->snippet->chunks ){
		last if($self->_is_current($c));
		my $text = blessed($c) && $c->can('to_string') ? $c->to_string : "$c";
		foreach my $char(split(/(\n)/,$text)){
			if($char eq "\n"){
				$y += length($char);
				$x = 0;
			} else {
				$x += length($char);
			}
		}
	}
	return [$x,$y];
}

1;
