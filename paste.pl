#!/usr/bin/env perl
use strict;
use CGI qw/:standard/;
use DBI;

my $DBFILE = "paste.db";
my $FILENAME_LENGTH=10;
my $PASTES_PATH="pastes/";

# return a random char
sub randomchar {
  return  chr(int(rand 26) + 96);
}

# create a random file path
sub newpath {
  my $path = "$PASTES_PATH/";
  for (my $i = 0; $i < $FILENAME_LENGTH; $i++) {
    $path .= randomchar;
  }
  return $path;
}

# fill the content of the page
sub fill {
  if (param("paste")) {

    # write the content to a random file
    my $path = newpath;
    open FILE, '>', $path;
    print FILE param("paste");

    # save the path to the file in the db
    my $db = DBI->connect("dbi:SQLite:dbname=$DBFILE","","",{AutoCommit => 0, PrintError => 1});
    # TODO: do that in one request only
    my $id = $db->do("select count (*) from pastes");
    $db->do("insert into pastes values ($id, '$path')");
    $db->disconnect();
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
