package MasterWebInterface::Database::Pg::Games;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw| dbGameListGet dbGetGameDesc |;

################################################################################
## get list of game details
## opt: filter first letter
################################################################################
sub dbGameListGet {
  my $s = shift;
  my %o = (page => 1, results => 50, sort => '', @_);
  
  my %where = (
    $o{firstchar} 
      ? ('upper(SUBSTRING(description from 1 for 1)) = ?' => $o{firstchar} ) : (),
    !$o{firstchar} && defined $o{firstchar} 
      ? ('ASCII(description) < 97 OR ASCII(description) > 122' => 1 ) : (),
    $o{search} 
      ? ('description ILIKE ?' => "%$o{search}%") : (),
  );
  
  my @select = ( qw| description gamename num_uplink num_total |);
  my $order = sprintf {
    description => 'description %s',
    gamename    => 'gamename %s',
    num_uplink  => 'num_uplink %s',
    num_total   => 'num_total %s',
  }->{ $o{sort}||'num_total' }, $o{reverse} ? 'DESC' : 'ASC';

  my($r, $np) = $s->dbPage(\%o, q|
    SELECT !s FROM games
      !W
      ORDER BY !s|,
    join(', ', @select), \%where, $order
  );

  my $p = $s->dbAll( q|
    SELECT COUNT(*) AS num
    FROM games
    !W|, \%where,
  )->[0]{num};
  return wantarray ? ($r, $np, $p) : $r;
}

################################################################################
## get description for a game by gamename
################################################################################
sub dbGetGameDesc {
my ($self, $gn) = @_;
  return $self->dbAll("SELECT description FROM games WHERE gamename = ?", $gn)->[0]{description};
}

1;
