package Text::Snippet::TabStop::WithTransformer;

use strict;
use warnings;
use base qw(Text::Snippet::TabStop);
use Carp qw(croak);
use Class::XSAccessor getters => { transformer => 'transformer' };

sub new {
	my $class = shift;
	my %args = @_;
	croak "transformer must be defined and a CodeRef" unless ref($args{transformer}) eq 'CODE';
	return bless \%args, $class;
}
sub to_string {
	my $self = shift;
	my $output = $self->SUPER::to_string;
	return $self->transformer->($output);
}
sub parse {
	my $class = shift;
	my $src = shift;
	if($src =~ m{^\$\{(\d+)/([^/]+?)/([^/]*)/(.*?)\}$}){
		my ($tab_index, $search, $replace, $flags) = ($1, $2, $3, $4);
		if(length($flags)){
			$search = "(?$flags$search)";
		}
		my $transformer = sub {
			my $out = shift;
			if($out =~ m/$search/){
				eval "\$out =~ s{\$search}{$replace}g";
			}
			return $out;
		};
		return $class->new( src => $src, index => $1, transformer => $transformer );
	}
	return;
}

1;
