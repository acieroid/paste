#!/usr/bin/env perl
use strict;
use CGI qw/:standard/;
use File::Basename;
use Syntax::Highlight::Engine::Kate;

my $FILENAME_LENGTH=10;
my $PASTES_PATH="pastes/";
my $MODE="debug"; # debug or something else 

# return a random char
sub randomchar {
  return  chr(int(rand 25) + ord('a'));
}

# create a random file path
sub newpath {
  my $path = "$PASTES_PATH";
  for (my $i = 0; $i < $FILENAME_LENGTH; $i++) {
    $path .= randomchar;
  }
  return $path;
}

# return an error message
sub error { 
  my $errtype = $_[0];
  my $errmsg = $_[1];
  if ($MODE eq "debug") {
    return h1($errtype) . p($errmsg);
  }
  else {
    return h1($errtype) . 
      p("Return to debug mode if you want more informations about the errors (set \$MODE as \"debug\"). You are in \"$MODE\" mode.");
  }
}

sub languagebox {
  my @languages = (new Syntax::Highlight::Engine::Kate())->languageList();
  my $box = "<select name=\"hl\" size=\"1\">\n";
  foreach my $lang (@languages) {
    $box .= "<option value=\"$lang\">$lang</option>\n";
  }
  return $box;
}

# fill the content of the page
sub fill {
  if (param("paste")) {
    # write the content to a random file
		my $path;
		do {
			$path = newpath;
		} while (-e $path);
		
    open (FILE, '>', $path) or 
      return error ("Internal error", "Error when opening $path : $!");
    print FILE param("paste");
		close FILE;
    return p("Your paste is located " . 
             a({href=>basename($0) . "?id=". basename($path) . "&hl=" .
               param("hl")}, "here"));
  }
  # View a paste
  elsif (param("id")) {
	  my $path = $PASTES_PATH . param("id");
    if (not -e $path) {
      return error "Wrong ID", "File doesn't exists : $path";
    }
    open (FILE, '<', $path) or 
      return error "Internal Error", "Error when opening : $path : $!";
    my $content;
    while (<FILE>) {
      $content .= $_;
    }
    if (param("hl")) {
      my $hl = new Syntax::Highlight::Engine::Kate(
        language => "Perl",
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
 
      if (grep { $_ eq param("hl") } $hl->languageList()) {
        $hl->language(param("hl"));
        $content = $hl->highlightText($content);
      }
    }
    return "<pre><code>\n" . $content . "\n</pre></code>";
  }
  else {
    # The paste page 
    return start_form() . 
           textarea(-name=>'paste',
                    -cols=>80, 
                    -rows=>20) .
           br . 
           languagebox() .
           submit("Paste it §") .
           end_form();
  }
}

print
  header(-charset => "UTF-8") . 
  start_html("Paste it §") .  
  h1("Paste it §") .
  fill . 
  end_html;

exit 0;
