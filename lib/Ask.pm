use 5.010;
use strict;
use warnings;

{
	package Ask;
	
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.000_01';
	
	use Carp qw(croak);
	use File::Which qw(which);
	use Moo::Role qw();
	use Module::Runtime qw(use_module use_package_optimistically);
	use namespace::sweep 0.006;
	
	sub detect {
		my $class  = shift;
		my %args   = @_==1 ? %{$_[0]} : @_;
		
		my $instance_class = $class->_detect_class_with_traits(\%args)
			or croak "Could not establish an appropriate Ask backend";
		
		return $instance_class->new(\%args);
	}
	
	my %_classes;
	sub _detect_class_with_traits {
		my ($class, $args) = @_;
		my @traits = @{ delete($args->{traits}) // [] };
		
		my $instance_class = $class->_detect_class($args);
		return unless defined $instance_class;
		return $instance_class unless @traits;
		
		# Cache class
		my $key = join q(|), $instance_class, sort @traits;
		$_classes{$key} //= "Moo::Role"->create_class_with_roles(
			$instance_class,
			@traits,
		);
	}
	
	sub _detect_class {
		my ($class, $args) = @_;
		
		if (exists $args->{class}) {
			return use_package_optimistically(delete $args->{class});
		}
		
		if (-t STDIN and -t STDOUT) {
			return use_module("Ask::STDIO");
		}

		if (eval { require Ask::Tk }) {
			return 'Ask::Tk';
		}

		if (my $zenity = which('zenity')) {
			$args->{zenity} //= $zenity;
			return use_module("Ask::Zenity");
		}
		
		return;
	}
}

1;

__END__

=head1 NAME

Ask - ask your users about stuff

=head1 SYNOPSIS

	use 5.010;
	use Ask;
	
	my $ask = Ask->detect;
	
	if ($ask->question(text => "Are you happy?")
	and $ask->question(text => "Do you know it?")
	and $ask->question(text => "Really want to show it?")) {
		$ask->info(text => "Then clap your hands!");
	}

=head1 DESCRIPTION

The C<Ask> suite is a set of modules for interacting with users; prompting
them for information, displaying messages, warnings and errors, etc.

There are already countless CPAN modules for doing this sort of thing, but
what sets C<Ask> apart from them is that C<Ask> will detect how your script
is being run (in a terminal, headless, etc) and choose an appropriate way
to interact with the user.

=head2 Class Method

=over

=item C<< Ask->detect(%arguments) >>

A constructor, sort of. It inspects the program's environment and returns an
object that implements the Ask API (see below).

Note that these objects don't usually inherit from C<Ask>, so the following
will typically be false:

	my $ask = Ask->detect(%arguments);
	$ask->isa("Ask");

Instead, check:

	my $ask = Ask->detect(%arguments);
	$ask->DOES("Ask::API");

=back

=head2 The Ask API

Objects returned by the C<detect> method implement the Ask API. This
section documents that API.

The following methods are provided by objects implementing the Ask
API. They are largely modeled on the interface for GNOME Zenity.

=over

=item C<< info(text => $text, %arguments) >>

Display a message to the user.

Setting the argument C<no_wrap> to true can be used to I<hint> that line
wrapping should be avoided.

=item C<< warning(text => $text, %arguments) >>

Display a warning to the user.

Supports the same arguments as C<info>.

=item C<< error(text => $text, %arguments) >>

Display an error message (not necessarily fatal) to the user.

Supports the same arguments as C<info>.

=item C<< entry(%arguments) >>

Ask the user to enter some text. Returns that text.

The C<text> argument is supported as a way of communicating what you'd like
them to enter. The C<hide_text> argument can be set to true to I<hint> that
the text entered should not be displayed on screen (e.g. password input).

=item C<< question(text => $text, %arguments) >>

Ask the user to answer a affirmative/negative question (i.e. OK/cancel,
yes/no) defaulting to affirmative. Returns boolean.

The C<text> argument is the text of the question; the C<ok_label> argument
can be used to set the label for the affirmative button; the C<cancel_label>
argument for the negative button.

=item C<< file_selection(%arguments) >>

Ask the user for a file name. Returns the file name. No checks are made to
ensure the file exists.

The C<multiple> argument can be used to indicate that multiple files may be
selected (they are returned as a list); the C<directory> argument can be
used to I<hint> that you want a directory.

=back

If you wish to create your own implementation of the Ask API, please
read L<Ask::API> for more information.

=head2 Extending Ask

Implementing L<Ask::API> allows you to extend Ask to other environments.

To add extra methods to the Ask API you may use Moo roles:

	{
		package AskX::Method::Password;
		use Moo::Role;
		sub password {
			my ($self, %o) = @_;
			$o{hide_text} //= 1;
			$o{text}      //= "please enter your password";
			$self->entry(%o);
		}
	}

	my $ask = Ask->detect(traits => ['AskX::Method::Password']);
	say "GOT: ", $ask->password;

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Ask>.

=head1 SEE ALSO

See L<Ask::API> for documentation of API internals.

Bundled API implementations are L<Ask::STDIO> and L<Ask::Zenity>.

Similar modules: L<IO::Prompt>, L<IO::Prompt::Tiny> and many others.

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

