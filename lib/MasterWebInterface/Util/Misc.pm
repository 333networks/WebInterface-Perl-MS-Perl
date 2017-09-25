package MasterWebInterface::Util::Misc;
use strict;
use warnings;
use TUWF ':html';
use POSIX 'strftime';
use Exporter 'import';
use Encode 'encode_utf8';
use Geography::Countries;
use Unicode::Normalize 'NFKD';
use Socket 'inet_pton', 'inet_ntop', 'AF_INET', 'AF_INET6';
our @EXPORT = qw| date_new timeformat countryflag valid_address |;

################################################################################
# time formatting for when a server was added
################################################################################
sub date_new {
  my ($s, $d) = @_;
  #return (strftime "%a %H:%M:%S", gmtime $d);
  return (strftime "%a %H:%M", gmtime $d); # no seconds
}

################################################################################
# time formatting for when a server was added / last updated
################################################################################
sub timeformat {
  my ($self, $time) = @_;
  
  # parse seconds with gmtime
  my @t = gmtime($time);
  my $r = "";

  # parse into d HH:mm:SS format
  if ($t[7]){$r .= $t[7]."d "}
  if ($t[2]){$r .= ($t[2] > 9) ? $t[2].":" : "0".$t[2].":" }
  if ($t[1]){$r .= ($t[1] > 9) ? $t[1].":" : "0".$t[1].":" } else {$r .= "00:";}
  if ($t[0]){$r .= ($t[0] > 9) ? $t[0] : "0".$t[0]         } else {$r .= "00";}
  
  return $r;
}

################################################################################
# returns flag, country name
################################################################################
sub countryflag {
  my ($self, $c) = @_;
  my $flag = ($c ? lc $c : 'earth');
  my $coun = $c ? ( $c eq 'EU' ? 'Europe' : country $c ) : 'Earth' ;
  return $flag, $coun;  
}

################################################################################
# Verify whether a given domain name or IP address and port are valid.
# returns the valid ip-address + port, or 0 when not.
################################################################################
sub valid_address {
  my ($self, $a, $p) = @_;

  # check if ip and port are in valid range
  my $val_addr = ($a =~ '^(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$') if $a;
  my $val_port = ($p =~  m/^\d+$/ && 0 < $p && $p <= 65535) if $p;
  
  # exclude local addresses
  if ($a =~ m/192.168.(\d).(\d)/ || $a =~ m/127.0.(\d).(\d)/ || $a =~ m/10.0.(\d).(\d)/) { $val_addr = 0; }
  
  # return valid params
  return (
    $val_addr ? $a : 0,
    $val_port ? $p : 0
  );
}

1;
