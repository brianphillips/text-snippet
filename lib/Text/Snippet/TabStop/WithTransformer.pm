package Text::Snippet::TabStop::WithTransformer;

use strict;
use warnings;
use Moose;
use MooseX::Types::Moose qw(CodeRef);

with qw(Text::Snippet::TabStop);
has transformer => (
	is => 'rw',
	isa => CodeRef,
	required => 1,
);
around 'to_string' => sub {
	my $next = shift;
	my $self = shift;
	my $output = $next->($self, @_);
	return $self->transformer->($output);
};

no Moose;

__PACKAGE__->meta->make_immutable;

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
