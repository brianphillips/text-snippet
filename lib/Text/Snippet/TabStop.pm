package Text::Snippet::TabStop;

use strict;
use warnings;
use Carp qw(croak);
use Moose::Role;
use MooseX::Types::Moose qw(Str Int);

requires( 'parse' );
has src => (
	is => 'ro',
	isa => Str,
	required => 1,
);
has index => (
	is => 'ro',
	isa => Int,
	required => 1,
);
has replacement => (
	is => 'rw',
	isa => Str,
	required => 0,
	writer => 'replace',
	default => '',
);
has parent => (
	is        => 'rw',
	does      => 'Text::Snippet::TabStop',
	required  => 0,
	predicate => 'has_parent',
);

no Moose::Role;

sub to_string {
	my $self = shift;
	return $self->parent->to_string if($self->has_parent);
	return $self->replacement;
}

sub is_terminal {
	return shift->index == 0;
}

1;
