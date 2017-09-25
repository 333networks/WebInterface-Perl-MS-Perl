package MasterWebInterface::Handler::Games;
use strict;
use TUWF ':html';
use Exporter 'import';
use Geography::Countries;

TUWF::register(
  qr{g}                 => \&gamelist,
  qr{g/}                => \&gamelist,
  qr{g/(all|[a-z])}     => \&gamelist,
  qr{g/(.[\w]*)}        => \&redirect_game,
);

# redirect to /s/gamename (compatibility with old urls -- remove eventually)
sub redirect_game {
  my ($self, $g) = @_;
  return $self->resRedirect("/s/$g");
}

################################################################################
# LIST GAMES
# Generate a list of games in the database (arg: gamename)
################################################################################
sub gamelist {
  my($self, $char) = @_;
  
  # default list if nothing defined
  $char = "all" unless $char; 
  
  # process additional query information, such as order, sorting, page, etc
  my $f = $self->formValidate(
    { get => 's', required => 0, default => 'num_total', enum => [ qw| description gamename num_uplink num_total | ] },
    { get => 'o', required => 0, default => 'd', enum => [ 'a','d' ] },
    { get => 'p', required => 0, default => 1, template => 'page' },
    { get => 'q', required => 0, default => '', maxlength => 30 },
  );
  return $self->resNotFound if $f->{_err};

  # load server list from database
  my($list, $np, $p) = $self->dbGameListGet(
    sort => $f->{s}, 
    reverse => $f->{o} eq 'd',
    $char ne 'all' ? (
      firstchar => uc $char ) : (),
    results => 50,
    search => $f->{q},
    page => $f->{p},
  );
  
  $self->htmlHeader(title => "Browse Games");
  
  div class => 'mainbox';
    div class => "header";
      h1 'Browse Games';
      p class => "alttitle", "An overview of all registered games, direct uplinks to our masterserver and the total amount of servers seen.";
    end;
    
   form action => "/g/$char", 'accept-charset' => 'UTF-8', method => 'get';
    $self->htmlSearchBox('g', $f->{q});
   end;
   p class => 'browseopts';
    for ('all', 'a'..'z') {
      a href => "/g/$_", $_ eq $char ? (class => 'optselected') : (), $_ eq 'all' ? ('all') : $_ ? uc $_ : '#';
    }
   end;
  end;
    
  # print list
  $self->htmlBrowse(
    items    => $list,
    options  => $f,
    total    => $p,
    nextpage => [$p,50],#$np,
    pageurl  => "/g/$char?o=$f->{o};s=$f->{s};q=$f->{q}",
    sorturl  => "/g/$char?q=$f->{q}",
    class    => "gamelist",
    ($p <= 0) ? (footer => sub {Tr;td colspan => 4, class => 'tc2', 'No games found.';end 'tr';}) : (),
    header   => [
        [ 'Game',       'description' ],
        [ 'Code',       'gamename'    ],
        [ 'Direct',     'num_uplink'   ],
        [ 'Total',      'num_total'    ],
    ],
    row     => sub {
      my($s, $n, $l) = @_;
      Tr $n % 2 ? (class => 's odd') : (class => 's');
        td class => "tc1"; a href => "/s/$l->{gamename}", $l->{description};end;
        td $l->{gamename};
        td $l->{num_uplink};
        td $l->{num_total};
      end;
    },
  );
  
  $self->htmlFooter;
}
1;
