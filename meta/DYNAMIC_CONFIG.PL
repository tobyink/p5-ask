if ( $ENV{'TRAVIS'} ) {
	delete $meta->{prereqs}{runtime}{recommends}{'Gtk2'};
	delete $meta->{prereqs}{runtime}{recommends}{'Tk'};
	delete $meta->{prereqs}{runtime}{recommends}{'Wx'};
}
