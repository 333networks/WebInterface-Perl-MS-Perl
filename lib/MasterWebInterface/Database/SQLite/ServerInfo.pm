package MasterWebInterface::Database::SQLite::ServerInfo;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw| dbGetServerListInfo dbGetServerDetails dbGetPlayerInfo |;

################################################################################
## get server details for one or multiple servers
################################################################################
sub dbGetServerListInfo {
  my $s = shift;
  my %o = ( sort => '', @_ );
  
  my %where = (
    $o{id}          ? (         'id = ?' => $o{id})           : (),
    $o{ip}          ? (         'ip = ?' => $o{ip})           : (),
    $o{port}        ? (       'port = ?' => $o{port})         : (),
    $o{gamename}    ? (   'gamename = ?' => lc $o{gamename})  : (),
    $o{gamever}     ? (    'gamever = ?' => $o{gamever})      : (),
    $o{hostname}    ? (   'hostname = ?' => $o{hostname})     : (),
    $o{hostport}    ? (   'hostport = ?' => $o{hostport})     : (),
    $o{country}     ? (    'country = ?' => $o{country})      : (),
    $o{b333ms}      ? (     'b333ms = ?' => $o{b333ms})       : (),
    $o{blacklisted} ? ('blacklisted = ?' => $o{blacklisted})  : (),
    $o{added}       ? (  'added < datetime(?, \'unixepoch\')' => (time-$o{added}))   : (),
    $o{beacon}      ? ( 'beacon > datetime(?, \'unixepoch\')' => (time-$o{beacon}))  : (),
    $o{updated}     ? ('updated > datetime(?, \'unixepoch\')' => (time-$o{updated})) : (),
    $o{before}      ? ('updated < datetime(?, \'unixepoch\')' => (time-$o{before}))  : (),
  );
  
  my @select = ( qw| id ip port serverlist.gamename gamever hostname hostport country b333ms blacklisted description |,
    "strftime('\%s', added)   as e_added",
    "strftime('\%s', updated) as e_updated",
    "strftime('\%s', CURRENT_TIMESTAMP) - strftime('\%s', added)    as addiff",
    "strftime('\%s', CURRENT_TIMESTAMP) - strftime('\%s', updated)  as updiff",
  );

  my $order = sprintf {
      id          => 'id %s',
      ip          => 'ip %s',
      port        => 'port %s',
      gamename    => 'serverlist.gamename %s',
      gamever     => 'gamever %s',
      hostname    => 'hostname %s',
      hostport    => 'hostport %s',
      country     => 'country %s',
      b333ms      => 'b333ms %s',
      blacklisted => 'blacklisted %s',
      added       => 'added %s',
      beacon      => 'beacon %s',
      updated     => 'updated %s',
  }->{ $o{sort}||'id' }, $o{reverse} ? 'DESC' : 'ASC';

  return $s->dbAll( q|SELECT !s FROM serverlist
                      JOIN games ON serverlist.gamename = games.gamename
                      !W ORDER BY !s|.($o{limit} ? " LIMIT ?" : ""),
    join(', ', @select), \%where, $order, ($o{limit} ? $o{limit} : ()),
  );
}

################################################################################
## get server details for one or multiple UT servers
################################################################################
sub dbGetServerDetails {
  my $s = shift;
  my %o = (sort => '', @_ );
  
  my %where = (
    $o{id}                  ? ('server_id = ?'            => $o{id})                  : (),
    $o{minnetver}           ? ('minnetver = ?'            => $o{minnetver})           : (),
    $o{location}            ? ('location = ?'             => $o{location})            : (),
    $o{listenserver}        ? ('listenserver = ?'         => $o{listenserver})        : (),
    $o{adminname}           ? ('adminname = ?'            => $o{adminname})           : (),
    $o{adminemail}          ? ('adminemail = ?'           => $o{adminemail})          : (),
    $o{password}            ? ('password = ?'             => $o{password})            : (),
    $o{gametype}            ? ('gametype = ?'             => $o{gametype})            : (),
    $o{gamestyle}           ? ('gamestyle = ?'            => $o{gamestyle})           : (),
    $o{changelevels}        ? ('changelevels = ?'         => $o{changelevels})        : (),
    $o{maptitle}            ? ('maptitle = ?'             => $o{maptitle})            : (),
    $o{mapname}             ? ('mapname = ?'              => $o{mapname})             : (),
    $o{numplayers}          ? ('numplayers = ?'           => $o{numplayers})          : (),
    $o{maxplayers}          ? ('maxplayers = ?'           => $o{maxplayers})          : (),
    $o{minplayers}          ? ('minplayers = ?'           => $o{minplayers})          : (),
    $o{botskill}            ? ('botskill = ?'             => $o{botskill})            : (),
    $o{balanceteams}        ? ('balanceteams = ?'         => $o{balanceteams})        : (),
    $o{playersbalanceteams} ? ('playersbalanceteams = ?'  => $o{playersbalanceteams}) : (),
    $o{friendlyfire}        ? ('friendlyfire = ?'         => $o{friendlyfire})        : (),
    $o{maxteams}            ? ('maxteams = ?'             => $o{maxteams})            : (),
    $o{timelimit}           ? ('timelimit = ?'            => $o{timelimit})           : (),
    $o{goalteamscore}       ? ('goalteamscore = ?'        => $o{goalteamscore})       : (),
    $o{fraglimit}           ? ('fraglimit = ?'            => $o{fraglimit})           : (),
    $o{mutators}            ? ('mutators ILIKE ?'         => "%$o{mutators}%")        : (),
    $o{updated}             ? ('updated > to_timestamp(?)'=> (time-$o{updated}))      : (),
  );
  
  my @select = ( qw| server_id minnetver location listenserver adminname adminemail
    password gametype gamestyle changelevels maptitle mapname numplayers maxplayers
    minplayers botskill balanceteams playersbalanceteams friendlyfire maxteams 
    timelimit goalteamscore fraglimit mutators |,
    "strftime('\%s', updated) as e_updated2",
    "strftime('\%s', CURRENT_TIMESTAMP) - strftime('\%s', updated)  as updiff2",
  );

  my $order = sprintf {
    server_id     => 'server_id %s',
    minnetver     => 'minnetver %s',
    location      => 'location %s',
    listenserver  => 'listenserver %s',
    adminname     => 'adminname %s',
    adminemail    => 'adminemail %s',
    password      => 'password %s',
    gametype      => 'gametype %s',
    gamestyle     => 'gamestyle %s',
    changelevels  => 'changelevels %s',
    maptitle      => 'maptitle %s',
    mapname       => 'mapname %s',
    numplayers    => 'numplayers %s',
    maxplayers    => 'maxplayers %s',
    minplayers    => 'minplayers %s',
    botskill      => 'botskill %s',
    balanceteams  => 'balanceteams %s',
    playersbalanceteams => 'playersbalanceteams %s',
    friendlyfire  => 'friendlyfire %s',
    maxteams      => 'maxteams %s',
    timelimit     => 'timelimit %s',
    goalteamscore => 'goalteamscore %s',
    fraglimit     => 'fraglimit %s',
    mutators      => 'mutators %s',
    updated       => 'updated %s',
  }->{ $o{sort}||'server_id' }, $o{reverse} ? 'DESC' : 'ASC';

  return $s->dbAll( q|
    SELECT !s FROM extended_info
      !W
      ORDER BY !s|
      .($o{limit} ? " LIMIT ?" : ""),
    join(', ', @select), \%where, $order, ($o{limit} ? $o{limit} : ()),
  );
}

################################################################################
## get player details for one particular server
################################################################################
sub dbGetPlayerInfo {
  my $s = shift;
  my %o = (sort => '', @_ );
  
  my %where = (
    $o{server_id} ? ('server_id = ?' => $o{server_id}): (),
    $o{player}    ? (   'player = ?' => $o{player})   : (),
    $o{team}      ? (     'team = ?' => $o{team})     : (),
    $o{frags}     ? (    'frags = ?' => $o{frags})    : (),
    $o{mesh}      ? (     'mesh = ?' => $o{mesh})     : (),
    $o{skin}      ? (     'skin = ?' => $o{skin})     : (),
    $o{face}      ? (     'face = ?' => $o{face})     : (),
    $o{ping}      ? (     'ping = ?' => $o{ping})     : (),
    $o{ngsecret}  ? ( 'ngsecret = ?' => $o{ngsecret}) : (),
  );
  
  my @select = ( qw| server_id player team frags mesh skin face ping ngsecret | );
  my $order = sprintf {
    server_id => 'server_id %s',
    player    => 'player %s',
    team      => 'team %s',
    frags     => 'frags %s',
    mesh      => 'mesh %s',
    skin      => 'skin %s',
    face      => 'face %s',
    ping      => 'ping %s',
    ngsecret  => 'ngsecret %s',
  }->{ $o{sort}||'team' }, $o{reverse} ? 'DESC' : 'ASC';

  return $s->dbAll( q|SELECT !s FROM player_info !W ORDER BY !s|.($o{limit} ? " LIMIT ?" : ""),
    join(', ', @select), \%where, $order, ($o{limit} ? $o{limit} : ()),
  );
}

1;
