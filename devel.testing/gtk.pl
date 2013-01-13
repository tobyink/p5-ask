use Gtk2 -init;

my $msg = Gtk2::MessageDialog->new(
	undef,
	'destroy-with-parent',
	'info',
	'ok',
	'Hello World',
);
$msg->set_property('secondary-text', 'Salutations to all the nations!');
$msg->run;
