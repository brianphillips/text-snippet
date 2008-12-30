package Text::Snippet::TabStop::WithDefault;

use strict;
use warnings;
use base qw(Text::Snippet::TabStop);
use Carp qw(croak);
use Class::XSAccessor getters => { default => 'default' };

sub new {
	my $class = shift;
	my %args = (default=>'', @_);
	return bless \%args, $class;
}
sub replacement {
	my $self = shift;
	my $replacement = $self->SUPER::replacement;
	return defined $replacement ? $replacement : $self->default;
}

sub parse {
	my $class = shift;
	my $src = shift;
	if($src =~ m/\$\{(\d+):(.*)\}/){
		return $class->new( index => $1, src => $src, default => $2 || '' );
	}
	return;
}

1;
