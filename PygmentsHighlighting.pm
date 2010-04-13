package PygmentsHighlighting;

use strict;
use RPC::XML;
use RPC::XML::Client;
use vars qw(@ISA @EXPORT);

require Exporter;
@ISA = qw(Exporter); 
@EXPORT = qw( languages highlight );

my $port = 8001;
my $server = "http://localhost:" . $port . "/RPC2";

sub die_with_rpc_error {
  my ($err) = @_;
  die "Error code " . $err->code . "from RPC::XML :\n" . $err->string . "\n";
}

sub languages {
  my @languages;

  my $client = RPC::XML::Client->new($server);
  my $res = $client->send_request('list_languages');

  if ($res->type ne "fault") {
    foreach my $lang (@{$res->value}) {
      push (@languages, $lang);
    }
  }
  else {
    die_with_rpc_error($res);
  }
  return sort @languages;
}

sub highlight {
  my ($text, $lang) = @_;

  my $client = RPC::XML::Client->new($server);
  my $req = RPC::XML::request->new('highlight_code', 
                                   RPC::XML::string->new($text),
                                   RPC::XML::string->new($lang));
  my $res = $client->send_request($req);
  if ($res->type ne "fault") {
    return $res->value;
  }
  else {
    die_with_rpc_error($res);
  }
}
