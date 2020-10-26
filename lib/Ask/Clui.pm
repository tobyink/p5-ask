use 5.008008;
use strict;
use warnings;

package Ask::Clui;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.011';

use Moo;
use Term::Clui 1.65 ();
use Path::Tiny 'path';
use Term::ANSIColor 'colored';
use namespace::autoclean;

with 'Ask::API';

sub BUILD {
	STDOUT->autoflush( 1 );
}

sub is_usable {
	my ($self) = @_;
	-t STDIN and -t STDOUT;
}

sub quality {
	my ( $self ) = ( shift );
	( -t STDIN and -t STDOUT ) ? 90 : 30;
}

sub info {
	my ( $self, %opts ) = ( shift, @_ );
	chomp( my $text = $opts{text} );
	Term::Clui::inform( $opts{text} );
	return;
}

sub warning {
	my ( $self, %opts ) = ( shift, @_ );
	chomp( my $text = $opts{text} );
	Term::Clui::inform( 'WARNING: ' . $opts{text} );
	return;
}

sub error {
	my ( $self, %opts ) = ( shift, @_ );
	chomp( my $text = $opts{text} );
	Term::Clui::inform( 'ERROR: ' . $opts{text} );
	return;
}

sub entry {
	my ( $self, %opts ) = ( shift, @_ );
	
	if ( $opts{hide_text} ) {
		return Term::Clui::ask_password( $opts{text} );
	}
	
	return Term::Clui::ask( $opts{text}, $opts{default}||'' );
}

sub question {
	my ( $self, %opts ) = ( shift, @_ );
	chomp( my $text = $opts{text} );
	return Term::Clui::confirm( $opts{text} );
}

my $_choices = sub {
	my $ref = shift;
	map $_->[0], @$ref;
};

sub single_choice {
	my ( $self, %opts ) = ( shift, @_ );
	local $ENV{CLUI_DIR} = 'OFF';
	scalar Term::Clui::choose( $opts{text}, $_choices->($opts{choices}) );
}

sub multiple_choice {
	my ( $self, %opts ) = ( shift, @_ );
	local $ENV{CLUI_DIR} = 'OFF';
	Term::Clui::choose( $opts{text}, $_choices->($opts{choices}) );
}

sub file_selection {
	my ( $self, %opts ) = ( shift, @_ );
	
	my @chosen;
	
	FILE: {
		my $got = Term::Clui::ask_filename( $opts{text} );
		
		if ( not length $got ) {
			last FILE if $opts{multiple};
			redo FILE;
		}
		
		$got = path $got;
		
		if ( $opts{existing} and not $got->exists ) {
			$self->error( text => 'Does not exist.' );
			redo FILE;
		}
		
		if ( $opts{directory} and not $got->is_dir ) {
			$self->error( text => 'Is not a directory.' );
			redo FILE;
		}
		
		push @chosen, $got;
		
		if ( $opts{multiple} ) {
			$self->info( text => 'Enter another file, or leave blank to finish.' );
			redo FILE;
		}
	};
	
	$opts{multiple} ? @chosen : $chosen[0];
}

1;
