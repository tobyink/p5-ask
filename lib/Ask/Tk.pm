use 5.010;
use strict;
use warnings;

{
	package Ask::Tk;
	
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.000_01';

	use Moo;
	use Tk;
	use namespace::sweep;

	with 'Ask::API';
	
	sub info {
		my ($self, %o) = @_;
		
		my $mw = "MainWindow"->new;
		$mw->withdraw;
		
		$o{messagebox_type} //= 'ok';
		$o{messagebox_icon} //= 'info';
		
		return $mw->messageBox(
			-title   => $o{title},
			-message => $o{text},
			-type    => $o{messagebox_type},
			-icon    => $o{messagebox_icon},
		);
	}
	
	sub warning {
		my ($self, %o) = @_;
		$self->info(messagebox_icon => 'warning', %o);
	}

	sub error {
		my ($self, %o) = @_;
		$self->info(messagebox_icon => 'error', %o);
	}

	sub question {
		my ($self, %o) = @_;
		'Ok' eq $self->info(
			messagebox_icon => 'question',
			messagebox_type => 'OkCancel',
			%o,
		);
	}

	sub entry {
		my ($self, %o) = @_;
		my $mw = "MainWindow"->new;
		
		$mw->Label(-text => $o{text})->pack
			if exists $o{text};
		
		my $return = $o{entry_text};
		my $entry = $mw->Entry(
			(-show        => '*') x!!( $o{hide_text} ),
			-relief       => 'ridge',
			-textvariable => \$return,
		)->pack;

		$entry->bind('<Return>', [ sub {
			$return = $entry->get;
			$mw->destroy;
		}]);
		
		$entry->focus;
		MainLoop;
		return $return;
	}
	
	sub file_selection {
		my ($self, %o) = @_;
		my @files;
		my $mw = "MainWindow"->new;
		$mw->withdraw;
		
		my %TK = (
			-type   => $o{directory} ? 'dir' : ($o{save} ? 'save' : 'open'),
		);
		
		push @files, $mw->FBox(%TK)->Show;
		while ($o{multiple} and $self->question(text => 'Select another?')) {
			push @files, $mw->FBox(%TK)->Show;
		}
		
		return @files;
	}
}

1;