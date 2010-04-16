#!/usr/bin/env perl
use strict;
use CGI qw/:standard/;
use File::Basename;
use PygmentsHighlighting;

my $FILENAME_LENGTH=10;
my $PASTES_PATH="pastes/";
my $MODE="debug"; # debug or something else 
my $TITLE="Paste it §";
my $BASE_URL=basename($0);

# return a random char
sub randomchar {
  return  chr(int(rand 25) + ord('a'));
}

# create a random file path
sub newpath {
  my $path = "$PASTES_PATH";
  for (my $i = 1; $i < $FILENAME_LENGTH; $i++) {
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

sub options_box {
  # Languages
  my @languages = languages();
  my $box = "<select name=\"hl\" size=\"1\">\n";
  foreach my $lang (@languages) {
    if (ref $lang eq "ARRAY") {
      $box .= "<option value=\"" . @{$lang}[1] . "\">" . 
              @{$lang}[0] . "</option>\n";
    }
    else {
      $box .= "<option value=\"$lang\">$lang</option>"
    }
  }
  $box .= "</select>\n";

  # Disable highlight
  $box .= checkbox(-name=>'no-hl', 
                   -label=>"No highlighting ", 
                   -checked=>1);
  
  # Disable html escaping
  $box .= checkbox(-name=>'no-escape', -label=>"No html escaping");
  return $box;
}

sub language_found {
  my ($lang) = @_;
  my @languages = languages;
  if (ref @languages[0] eq "ARRAY") {
    return grep { @{$_}[1] eq $lang } languages();
  }
  else {
    return grep { $_ eq $lang } languages()
  }
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

    my $url = $BASE_URL . "?id=" . basename($path);
    $url .= "&hl=" . param("hl") if (not (param("no-hl") eq "on"));
    $url .= "&ne=t" if (param("no-escape") eq "on");
    return p("Your paste is located " . a({href=>$url}, "here"));
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
      if (param("ne")) {
        $content .= $_;
      }
      else {
        $content .= escapeHTML($_);
      }
    }
    if (param("hl") and language_found(param("hl"))) {
      if (param("ne")) {
        $content = highlight($content, param("hl"));
      }
      else {
        $content = highlight(unescapeHTML($content), param("hl"));
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
           options_box() .
           submit("Paste it §") .
           end_form();
  }
}

print
  header(-charset => "UTF-8") . 
  start_html(-title => $TITLE, 
             -style => "paste.css") .  
  h1($TITLE) .
  fill . 
  end_html;

exit 0;
