package MasterWebInterface::Handler::Servers;
use strict;
use utf8;
use TUWF ':html';
use Exporter 'import';
use Geography::Countries;

TUWF::register(
  qr{s/(.[\w]*)}              => \&serverlist,
  qr{s/(.[\w]*)/(all|[0a-z])} => \&serverlist,
);

################################################################################
# List servers
# Generate a list of selected games in the database per game (arg: gamename)
################################################################################
sub serverlist {
  my($self, $gamename, $char) = @_;
  
  # default list if nothing defined
  $char = "all" unless $char; 
  
  # process additional query information, such as order, sorting, page, etc
  my $f = $self->formValidate(
    { get => 's', required => 0, default => 'diff', enum => [ qw| country hostname description gamename gametype ip hostport numplayers mapname diff added | ] },
    { get => 'o', required => 0, default => 'a', enum => [ 'a','d' ] },
    { get => 'p', required => 0, default => 1, template => 'page' },
    { get => 'q', required => 0, default => '', maxlength => 90 },
  );
  return $self->resNotFound if $f->{_err};

  # load server list from database
  my($list, $np, $p) = $self->dbServerListGet(
    sort => $f->{s}, 
    reverse => $f->{o} eq 'd',
    $char ne 'all' ? (
      firstchar => uc $char ) : (),
    results => 50,
    search => $f->{q},
    gamename => $gamename,
    page => $f->{p},
  );
  
  # game name description in title
  my $gn_desc = $self->dbGetGameDesc($gamename) || $gamename;

  # Write page  
  $self->htmlHeader(title => "Browse $gn_desc game servers");
  
  div class => 'mainbox';
    div class => "header";
      h1 'Browse Servers';
      p class => "alttitle";
        txt "Servers listed for ";
        span class => "acc", $gn_desc;
        txt " games. Can be sorted by location, server name, gametype, players and current map.";
      end;
    end;

   form action => "/s/$gamename/all", 'accept-charset' => 'UTF-8', method => 'get';
    $self->htmlSearchBox('s', $f->{q});
   end;
   p class => 'browseopts';
    for ('all', 'a'..'z', 0) {
      a href => "/s/$gamename/$_", $_ eq $char ? (class => 'optselected') : (), $_ eq 'all' ? ('all') : $_ ? uc $_ : '#';
    }
   end;
  end;
    
  # print list
  $self->htmlBrowse(
    items    => $list,
    options  => $f,
    total    => $p,
    nextpage => [$p,50],#$np,
    pageurl  => "/s/$gamename/$char?o=$f->{o};s=$f->{s};q=$f->{q}",
    sorturl  => "/s/$gamename/$char?q=$f->{q}",
    class    => "serverlist",
    ($p <= 0) ? (footer => sub {Tr;td colspan => 6, class => 'tc2', 'No online servers found';end 'tr';}) : (),
    header   => [
        [ '',             'country'     ],
        [ 'Server Name',  'hostname'    ],
        [ 'Game',         'gamename'    ],
        [ 'Gametype',     'gametype'    ],
        [ 'Players',      'numplayers'  ],
        [ 'Map',          'mapname'    ],
    ],
    row     => sub {
      my($s, $n, $l) = @_;
      Tr $n % 2 ? (class => 's odd') : (class => 's');
        my ($flag, $country) = $self->countryflag($l->{country});
        td class => "tc1 flag", style => "background-image: url(/flag/$flag.svg);", title => $country, '';
        td class => "tc2"; a href => "/$l->{gamename}/$l->{ip}:$l->{hostport}", $l->{hostname}; end;
        td class => "tc3", title => $l->{description}; a href => "/s/$l->{gamename}", $l->{gamename};end;
        td class => "tc4", title => $l->{gametype}, $l->{gametype};
        td class => "tc5"; txt $l->{numplayers}; txt "/"; txt $l->{maxplayers}; end;
        td class => "tc6", title => ( $l->{maptitle} || $l->{mapname}), ($l->{maptitle} || $l->{mapname});
      end;
    },
  );

  $self->htmlFooter;
}

1;
