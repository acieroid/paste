package KateHighlighting;

use strict;
use Syntax::Highlight::Engine::Kate;
use vars qw(@ISA @EXPORT);

require Exporter;
@ISA = qw(Exporter); 
@EXPORT = qw( languages highlight );

sub languages {
  return (new Syntax::Highlight::Engine::Kate())->languageList();
}

sub highlight {
  my ($text, $lang) = @_;
  my $hl = new Syntax::Highlight::Engine::Kate(
    language => $lang,
    substitutions => {
       "<" => "&lt;",
       ">" => "&gt;",
    },
    format_table => {
       Alert => ["<font color=\"#0000ff\">", "</font>"],
       BaseN => ["<font color=\"#007f00\">", "</font>"],
       BString => ["<font color=\"#c9a7ff\">", "</font>"],
       Char => ["<font color=\"#ff00ff\">", "</font>"],
       Comment => ["<font color=\"#7f7f7f\"><i>", "</i></font>"],
       DataType => ["<font color=\"#0000ff\">", "</font>"],
       DecVal => ["<font color=\"#00007f\">", "</font>"],
       Error => ["<font color=\"#ff0000\"><b><i>", "</i></b></font>"],
       Float => ["<font color=\"#00007f\">", "</font>"],
       Function => ["<font color=\"#007f00\">", "</font>"],
       IString => ["<font color=\"#ff0000\">", ""],
       Keyword => ["<b>", "</b>"],
       Normal => ["", ""],
       Operator => ["<font color=\"#ffa500\">", "</font>"],
       Others => ["<font color=\"#b03060\">", "</font>"],
       RegionMarker => ["<font color=\"#96b9ff\"><i>", "</i></font>"],
       Reserved => ["<font color=\"#9b30ff\"><b>", "</b></font>"],
       String => ["<font color=\"#ff0000\">", "</font>"],
       Variable => ["<font color=\"#0000ff\"><b>", "</b></font>"],
       Warning => ["<font color=\"#0000ff\"><b><i>", "</b></i></font>"],
    },
  );
  return $hl->highlightText($text);
}
