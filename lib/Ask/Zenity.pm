use 5.010;
use strict;
use warnings;

{
	package Ask::Zenity;
	
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.003';
	
	use Moo;
	use System::Command;
	use namespace::sweep;
	
	has zenity_path => (
		is       => 'ro',
		isa      => sub { die "$_[0] not executable" unless -x $_[0] },
		default  => sub { '/usr/bin/zenity' },
	);
	
	has system_wrapper => (
		is       => 'ro',
		default  => sub { 'System::Command' },
	);
	
	with 'Ask::API';
	
	sub _optionize {
		my $opt = shift;
		$opt =~ s/_/-/g;
		return "--$opt";
	}
	
	sub _zenity {
		my ($self, $cmd, %o) = @_;
		my $zen = $self->system_wrapper->new(
			$self->zenity_path,
			_optionize($cmd),
			map sprintf('%s=%s', _optionize($_), $o{$_}), keys %o,
		);
		# warn join q[ ], $zen->cmdline;
		return $zen;
	}
	
	sub entry {
		my $self = shift;
		my $text = readline($self->_zenity(entry => @_)->stdout);
		chomp $text;
		return $text;
	}

	sub info {
		my $self = shift;
		$self->_zenity(info => @_);
	}

	sub warning {
		my $self = shift;
		$self->_zenity(warning => @_);
	}

	sub error {
		my $self = shift;
		$self->_zenity(error => @_);
	}

	sub question {
		my $self = shift;
		my $zen  = $self->_zenity(error => @_);
		$zen->close;
		return not $zen->exit;
	}
	
	sub file_selection {
		my $self = shift;
		my $text = readline($self->_zenity(file_selection => @_)->stdout);
		chomp $text;
		return split m#[|]#, $text;
	}
}

1;

__END__

=head1 NAME

Ask::Zenity - use C<< /usr/bin/zenity >> to interact with a user

=head1 SYNOPSIS

	my $ask = Ask::Zenity->new(
		zenity_path => '/usr/bin/zenity',
	);
	
	$ask->info(text => "I'm Charles Xavier");
	if ($ask->question(text => "Would you like some breakfast?")) {
		...
	}

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Ask>.

=head1 SEE ALSO

L<Ask>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012-2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

