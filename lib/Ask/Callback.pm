# This primarily exists for testing... but you can use it too!
#

use 5.010;
use strict;
use warnings;

{
	package Ask::Callback;
	
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.001';
	
	use Moo;
	use namespace::sweep;
	
	with 'Ask::API';
	
	has input_callback  => (is => 'ro', required => 1);
	has output_callback => (is => 'ro', required => 1);
	
	sub entry {
		my ($self) = @_;
		return $self->input_callback->();
	}

	sub info {
		my ($self, %o) = @_;
		return $self->output_callback->($o{text});
	}
}

1;
