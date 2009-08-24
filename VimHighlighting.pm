package VimHighlighting;

use strict;
use Text::VimColor;
use vars qw(@ISA @EXPORT);

require Exporter;
@ISA = qw(Exporter); 
@EXPORT = qw( languages highlight );

my $VIM_SHARE_PATH = "/usr/share/vim";

sub languages {
  my @languages;
  #TODO: what to do if we can't open it?
  opendir (SYNTAXDIR, "$VIM_SHARE_PATH/syntax/");
  foreach my $file (readdir SYNTAXDIR) {
    if ($file =~ /.vim$/) {
      $file =~ s/.vim$//;
      push (@languages, $file);
    }
  }
  return sort @languages;
}

sub highlight {
  my ($text, $lang) = @_;
  my $syntax = Text::VimColor->new(
     string => $text,
     filetype => $lang,
     stylesheet => 1,
  );

  return $syntax->html;
}
