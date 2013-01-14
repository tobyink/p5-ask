use 5.010;
use strict;
use warnings;

{
	package Ask::Wx;
	
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.004';

	use Moo;
	use Wx;
	use namespace::sweep;

	with 'Ask::API';
	
	sub info
	{
		my ($self, %o) = @_;
		$o{messagebox_icon}    //= Wx::wxICON_INFORMATION();
		$o{messagebox_buttons} //= Wx::wxOK();
		Wx::MessageBox(
			($o{text}  // ''),
			($o{title} // 'Information'),
			$o{messagebox_icon} | $o{messagebox_buttons},
		);
	}
	
	sub warning
	{
		my ($self, %o) = @_;
		$self->info(messagebox_icon => Wx::wxICON_WARNING(), title => 'Warning', %o);
	}
	
	sub error
	{
		my ($self, %o) = @_;
		$self->info(messagebox_icon => Wx::wxICON_ERROR(), title => 'Error', %o);
	}
	
	sub question
	{
		my ($self, %o) = @_;
		Wx::wxYES() == $self->info(
			title => 'Question',
			messagebox_icon    => Wx::wxICON_QUESTION(),
			messagebox_buttons => Wx::wxYES_NO(),
			%o,
		);
	}
	
	sub entry
	{
		my ($self, %o) = @_;
		
		return Wx::GetPasswordFromUser( 
			($o{text}  // ''),
			($o{title} // 'Text entry'),
			($o{entry_text} // ''),
		) if $o{hide_text};
		
		return Wx::GetTextFromUser( 
			($o{text}  // ''),
			($o{title} // 'Text entry'),
			($o{entry_text} // ''),
		);
	}
	
	sub file_selection
	{
		my ($self, %o) = @_;
		
		return Wx::DirSelector($o{text} // '')
			if $o{dir};
		
		warn "Multiple file selection box not implemented in Ask::Wx yet!\n"
			if $o{multiple};
		
		return Wx::FileSelector( 
			($o{text} // ''),
			'',    # default path
			'',    # default filename
			'',    # default extension
			'*.*', # wildcard
			$o{save} ? Wx::wxFD_SAVE() : Wx::wxFD_OPEN()
		);
	}
}

1;

__END__

=head1 NAME

Ask::Gtk - interact with a user via a Gtk GUI

=head1 SYNOPSIS

	my $ask = Ask::Gtk->new;
	
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

