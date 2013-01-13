use 5.010;
use strict;
use warnings;

{
	package Ask::API;
	
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.003';
	
	use Moo::Role;
	
	requires 'entry';  # get a string of text
	requires 'info';   # display a string of text
	
	sub warning {
		my ($self, %o) = @_;
		$o{text} = "WARNING: $o{text}";
		return $self->info(%o);
	}

	sub error {
		my ($self, %o) = @_;
		$o{text} = "ERROR: $o{text}";
		return $self->info(%o);
	}

	sub question {
		my ($self, %o) = @_;
		
		$o{cancel} //= qr{^(no|n|cancel)$}i;
		
		my $response = $self->entry(text => $o{text});
		return !!1 if $response ~~ $o{ok};
		return !!0 if $response ~~ $o{cancel};
		return !!1;
	}
	
	sub file_selection {
		my ($self, %o) = @_;
		
		if ($o{multiple}) {
			$self->info(text => $o{text} // 'Enter file names (blank to finish)');
			my @filenames;
			while (my $f = $self->entry) {
				push @filenames, $f;
			}
			return @filenames;
		}
		else {
			return $self->entry(text => ($o{text} // 'Enter file name'));
		}
	}
}

1;

__END__

=head1 NAME

Ask::API - an API to ask users things

=head1 SYNOPSIS

	{
		package Ask::AwesomeWidgets;
		use Moo;
		with 'Ask::API';
		sub info {
			my ($self, %arguments) = @_;
			...
		}
		sub entry {
			my ($self, %arguments) = @_;
			...
		}
	}

=head1 DESCRIPTION

C<Ask::API> is a L<Moo> role. This means that you can write your
implementation as either a Moo or Moose class.

The only two methods that you absolutely must implement are C<info> and
C<entry>.

C<Ask::API> provides default implementations of C<warning>, C<error>,
C<question> and C<file_selection> methods, but they're not espcially
good, so you probably want to implement them too.

There is not currently any mechanism to "register" your implementation
with L<Ask> so that C<< Ask->detect >> knows about it.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Ask>.

=head1 SEE ALSO

L<Ask>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

