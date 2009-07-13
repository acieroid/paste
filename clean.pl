#!/usr/bin/env perl
# Use this script as a cron job
# it deletes all the files older than $MAX_TIME in the directory $PASTES_DIR
use strict;

my $MAX_TIME=60*60*24*7; # One week
my $PASTES_DIR="pastes/";

my $now = time ;

opendir(DIR, $PASTES_DIR) or die $!;
while (my $file = readdir DIR) {
	if ($file =~ m/\.{1,2}/) {
		next;
	}
	my $ctime = (stat($PASTES_DIR . '/' .  $file))[10];
	if ($now - $ctime > $MAX_TIME) {
		print "removing $file\n";
		unlink ($PASTES_DIR . '/' . $file);
	}
}
closedir(DIR)

