#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use CGI qw/:standard/;
use Net::IP;
use Text::CSV;
use Data::Dumper;
use MaxMind::DB::Reader;

my $q = CGI->new;

print $q->header;
print "<!DOCTYPE html>\n";
print "<HTML>";
my $str = <<'END';
<head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta charset="utf-8" />
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inconsolata:wght@200..900&display=swap" rel="stylesheet">

       <style>
            #map {
                height:400px;
                width:350px;
                margin:0px;
            }
	body {
	  font-family: Inconsolata;
	}
	header {
	  position: fixed;
	  top: 0;
	  width: 100%;
	  background-color: grey;
	  color:white;
	}
        </style>
</head>
<BODY>
<header>location.zakz.info</header><BR><BR>
END
;
print "$str \n";
print "Remote IP: $ENV{'REMOTE_ADDR'}<BR>";
# Process geoip
my $reader = MaxMind::DB::Reader->new( file =>'/var/local/ipgeo-community/ipgeo-community.mmdb');
my $ip = $ENV{'REMOTE_ADDR'};
my $record = $reader->record_for_address($ip);
my $cc = $record->{'country_code'};
my $timezone = $record->{'timezone'};
my $as_org = $record->{'as_org'};
my $is_datacenter = $record->{'is_datacenter'};

if ($cc eq ''){
  print "Local network.<BR>";
} else {
  print "Country: $cc<BR>Network: $as_org<BR>";
  print "Timezone: $timezone<BR>";
  if (length($is_datacenter)){
    print "Data Center: Yes <BR>";
  }
}
print "<BR><BR>Server information:";
print "<TABLE>";
foreach my $k (sort keys %ENV){
  next if ($k =~ /CONTEXT/);
  next if ($k =~ /DOCUMENT/);
  next if ($k =~ /GATEWAY/);
  next if ($k =~ /SCRIPT/);
  next if ($k =~ /SERVER/);
  next if ($k eq 'PATH');
  print "<TR><TD>$k</TD><TD>$ENV{$k}</TD></TR>";
}
print "</TABLE>";
print "<BR><BR><I>Logs are kept for diagnostic purposes only.  See <A href=\"/privacy.txt\">privacy policy</A>.</I>";
print "<BR>IP Geolocation data provided by <A HREF=\"https://github.com/whois-api-llc/ipgeo-community\">whois-api-llc/ipgeo-community</A> CC BY-SA 4.0.<BR>";
print "</BODY></HTML>";
