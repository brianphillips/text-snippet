package Text::Snippet::TabStop;

use strict;
use warnings;
use Carp qw(croak);
use overload '""' => sub { shift->to_string };

use Class::XSAccessor
		getters    => { src        => 'src', index => 'index', chunks => 'chunks', replacement => 'replacement' },
		setters    => { replace    => 'replacement' },
		accessors  => { parent     => 'parent' },
		predicates => { has_parent => 'parent' };

sub new {
	my $class = shift;
	my %args = @_;
	for my $k(qw(src index)){
		croak "$k is required" unless defined $args{$k};
	}
	return bless \%args, $class;
}

sub parse {
	croak "must be implemented in sub class";
}

sub to_string {
	my $self = shift;
	return $self->parent->to_string if($self->has_parent);
	return $self->replacement;
}

sub is_terminal {
	return shift->index == 0;
}

1;
