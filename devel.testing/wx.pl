use strict;
use 5.010;
use Wx;

say Wx::MessageBox("Question", "Icon Type:", Wx::wxICON_QUESTION()|Wx::wxOK());
say Wx::wxYES();

say Wx::GetTextFromUser( 
	"TEXT",
	"TITLE",
	"ENTRY TEXT",
);