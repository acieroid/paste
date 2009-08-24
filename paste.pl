#!/usr/bin/env perl
use strict;
use CGI qw/:standard/;
use File::Basename;
use VimHighlighting;

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
  my ($errtype, $errmsg) = $_;
  if ($MODE eq "debug") {
    return h1($errtype) . p($errmsg);
  }
  else {
    return h1($errtype) . 
      p("Return to debug mode if you want more informations about the errors (set \$MODE as \"debug\"). You are in \"$MODE\" mode.");
  }
}

sub languagebox {
  my @languages = languages();
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
    if (param("hl") 
        and grep { $_ eq param("hl") } languages()) {
      $content = highlight($content, param("hl"));
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
  start_html(-title => "Paste it §", 
             -style => "paste.css") .  
  h1("Paste it §") .
  fill . 
  end_html;

exit 0;
