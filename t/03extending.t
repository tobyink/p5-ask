use strict;
use warnings;
use Test::More;

BEGIN { delete $ENV{PERL_ASK_BACKEND} };

use Ask;

my @input;
my @output;

BEGIN {
	package AskX::Method::Password;
	use Moo::Role;
	sub password {
		my ($self, %o) = @_;
		$o{hide_text} //= 1;
		$o{text}      //= "please enter your password";
		$self->entry(%o);
	}
};

sub flush_buffers {
	@input = @output = ();
}

my $ask = Ask->detect(
	class           => 'Ask::Callback',
	traits          => ['AskX::Method::Password'],
	input_callback  => sub { shift @input },
	output_callback => sub { push @output, $_[0] },
);

{
	@input = 's3cr3t';
	is(
		$ask->password,
		's3cr3t',
	);
	flush_buffers();
}

done_testing;
