package MasterWebInterface::Database::SQLite::Servers;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw| dbAddServer dbServerListGet |;

################################################################################
## check if an ip, port/hostport combination is recent in the serverlist.
## if not, add the address to the pending list
################################################################################
sub dbAddServer {
  my $self = shift;
  my %o = (updated => 3600, @_ );

  my %where = (
    $o{ip}       ? (      'ip = ?' => $o{ip})       : (),
    $o{port}     ? (    'port = ?' => $o{port})     : (),
    $o{updated}  ? ('updated > datetime(?, \'unixepoch\')' => (time-$o{updated})) : (),
  );

  # determine if it already exsits
  my $u = $self->dbAll("SELECT id FROM serverlist !W", \%where)->[0];
  return 0 if $u;

  # else, insert in pending (duplicates may exist -- see remove_pending)
  $self->dbExec("INSERT INTO pending (ip, heartbeat) VALUES (?, ?)", $o{ip}, $o{port});
  return 1;
}

################################################################################
## get the serverlist. default 2 hours time limit
################################################################################
sub dbServerListGet {
  my $s = shift;
  my %o = ( page => 1, results => 50, sort => '', updated => '7200', @_ );
  
  my %where = (
    defined $o{gamename} && $o{gamename} !~ /all/ 
      ? ('serverlist.gamename = ?' => $o{gamename}) : (),
    $o{firstchar} 
      ? ('upper(SUBSTR(hostname, 1, 1)) = ?' => $o{firstchar} ) : (),
    $o{search} 
      ? ('lower(hostname) LIKE lower(?)' => "%$o{search}%") : (),
    $o{updated}  
      ? ('serverlist.updated > datetime(?, \'unixepoch\')' => (time-$o{updated})) : (),
    $o{filter}
      ? ('blacklisted = ?' => 0) : (),
#    ('length(hostname) > ?' => 1),  # don't show empty hostnames
    ('hostport > ?' => 0),          # or games with empty hostport
  );
  
  my @select = ( qw| id ip hostport hostname serverlist.gamename country numplayers maxplayers maptitle mapname gametype added description |,
    "strftime('\%s', CURRENT_TIMESTAMP) - strftime('\%s', serverlist.updated) as diff",
    "strftime('\%s', serverlist.updated) as updated",
    "strftime('\%s', serverlist.added)   as added");

  my $order = sprintf {
    id          => 'id %s',
    ip          => 'ip %s',
    hostport    => 'hostport %s',
    hostname    => 'hostname %s',
    gamename    => 'serverlist.gamename %s',
    country     => 'country %s',
    diff        => 'diff %s',
    added       => 'serverlist.added %s',
    updated     => 'updated %s',
    gametype    => 'gametype %s',
    numplayers  => 'numplayers %s',
    maxplayers  => 'maxplayers %s',
    mapname     => 'mapname %s',
    description => 'description %s',
  }->{ $o{sort}||'hostname' }, $o{reverse} ? 'DESC' : 'ASC';

  my($r, $np) = $s->dbPage(\%o, q|
    SELECT !s FROM serverlist
      JOIN games ON serverlist.gamename = games.gamename
      JOIN extended_info ON serverlist.id = extended_info.server_id
      !W
      ORDER BY !s|,
    join(', ', @select), \%where, $order
  );

  my $p = $s->dbAll( q|
    SELECT COUNT(*) AS num
    FROM serverlist
    !W|, \%where,
  )->[0]{num};
  return wantarray ? ($r, $np, $p) : $r;
}

1;
