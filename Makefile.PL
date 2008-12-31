use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME          => 'Text::Snippet',
	AUTHOR        => 'Brian Phillips <bphillips@cpan.org>',
	VERSION_FROM  => 'lib/Text/Snippet.pm',
	ABSTRACT_FROM => 'lib/Text/Snippet.pm',
	( $ExtUtils::MakeMaker::VERSION >= 6.3002
		? ( 'LICENSE' => 'perl' )
		: () ),
	PL_FILES  => {},
	PREREQ_PM => {
		'Test::More'        => 0,
		'Text::Balanced'    => 0,
		'Class::XSAccessor' => 0,
		'Test::Exception'   => 0,
	},
	dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean => { FILES    => 'Text-Snippet-*' },
);
