use strict;
use warnings;
use Test::More;

use Ask;

my @input;
my @output;

sub flush_buffers {
	@input = @output = ();
}

my $ask = Ask->detect(
	class           => 'Ask::Callback',
	input_callback  => sub { shift @input },
	output_callback => sub { push @output, $_[0] },
);

{
	@input = 'Bob';
	is(
		$ask->entry(text => 'Bob, what is your name?'),
		'Bob',
	);
	flush_buffers();
}

{
	@input = 'y';
	is(
		!!$ask->question(text => 'Will this test pass?'),
		!!1,
	);
	flush_buffers();
}

{
	@input = qw( file1.txt file2.txt file3.txt file4.txt );
	is(
		$ask->file_selection(text => 'Enter "file1.txt"'),
		'file1.txt',
	);
	is_deeply(
		[ $ask->file_selection(
			text     => 'Enter "file2.txt", "file3.txt" and "file4.txt"',
			multiple => 1,
		) ],
		[ qw( file2.txt file3.txt file4.txt ) ],
	);	
	flush_buffers();
}

{
	$ask->info(text => 'Argh!');
	is(
		$output[0],
		'Argh!',
	);
	flush_buffers();
}

{
	$ask->warning(text => 'Argh!');
	is(
		$output[0],
		'WARNING: Argh!',
	);
	flush_buffers();
}

{
	$ask->error(text => 'Argh!');
	is(
		$output[0],
		'ERROR: Argh!',
	);
	flush_buffers();
}

done_testing;
