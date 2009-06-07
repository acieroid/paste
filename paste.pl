#!/usr/bin/env perl
use strict;
use CGI qw/:standard/;
use DBI;

my $DBFILE = "paste.db";
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
      p("Return to debug mode if you want more informations about the errors");
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

    # save the path to the file in the db
    my $db = DBI->connect("dbi:SQLite:dbname=$DBFILE","","",
                            {AutoCommit => 0, PrintError => 1});
    # TODO: do that in one request only
    my $id = $db->do("select count (*) from pastes");
    $db->do("insert into pastes values ($id, '$path', " . time  . ")");

    if ($db->err) { 
      return error("Internal error", $db->errstr);
    } 

		$db->commit();
    $db->disconnect();
		# TODO: output something ?
  }
  else {
    # The paste page 
    return start_form() . 
           textarea(-name=>'paste',
                    -cols=>80, 
                    -rows=>20) .
           br . 
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
