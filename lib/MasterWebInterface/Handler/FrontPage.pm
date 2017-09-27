package MasterWebInterface::Handler::FrontPage;
use strict;
use warnings;
use utf8;
use TUWF ':html';
use Exporter 'import';
our @EXPORT = qw| _box_content |;

TUWF::register(
  qr{} => \&main,
);

################################################################################
# Front page
# Contains list of new servers and boxes with information and stats.
################################################################################
sub main {
  my ($self, @args) = @_;
  
  # workaround for lists -- record options, but don't use them.
  my $f = $self->formValidate(
    { get => 's', required => 0, default => '', enum => [  ] },
    { get => 'o', required => 0, default => 'd', enum => [ 'a','d' ] },
    { get => 'p', required => 0, default => 1, template => 'page' },
    { get => 'q', required => 0, default => '', maxlength => 30 },
  );
  
  $self->htmlHeader(title => "Welcome");
  
  # load NEW SERVERS list from database
  my ($list, $np, $p) = $self->dbServerListGet(results => 8, sort => 'added', reverse => 1, filter => 1);
  my $odd = 0;
  
  # print list of new servers added to the database
  $self->htmlBrowse(
    items    => $list,
    options  => $f,
    total    => $p,
    nextpage => 0,
    pageurl  => "/s/all/all",
    sorturl  => "/s/all/all",
    class    => "newservers",
    footer => sub {
      Tr ++$odd % 2 ? (class => 'even') : (class => 'odd'), id => "tfooter";
        td colspan => 4; 
          txt "Add your server ";
          a href => '/new', 'here'; 
          txt "!";
        end;
      end 'tr';},
    ($p <= 0) ? (footer => sub {Tr;td colspan => 4, class => 'tc2', 'No recent servers found';end 'tr';}) : (),
    header   => [
        [ '',               'country' ],
        [ 'Newest servers', 'hostname'],
        [ 'Game',           'description'],
        [ 'Added',          'added'   ],
    ],
    row     => sub {
      my($s, $n, $l) = @_;
      Tr $n % 2 ? (class => 's odd') : (class => 's');
        my ($flag, $country) = $self->countryflag($l->{country});
        td class => "tc1 flag", style => "background-image: url(/flag/$flag.svg);", title => $country, '';
        td class => "tc2"; a href => "/$l->{gamename}/$l->{ip}:$l->{hostport}", $l->{hostname}; end;
        td class => "tc3"; a href => "/s/$l->{gamename}", $l->{description};end;
        td $self->date_new($l->{added});
      end;
      $odd = $n; # for footer
    },
  ); 

  # opening and welcome
  div class => "mainbox";
    div class => "header";
      h2 "Welcome to $self->{site_name}";
    end;
    p "On this website, you find a plain overview of all server addresses that are listed in our masterserver and all games that are currently supported. On this website you can also find links to instructions to add your online server to the masterserver, and how to receive the list from our masterserver as game player.";
  end;
  br style => "clear:both";  

#  div class => 'notice';
#    h2 "Generic Title";
#    p "Generic paragraph.";
#  end;      

  #
  # two-sided pane with multiple boxes
  div class => "frontcontainer";
    div class => "frontleft";
      $self->_box_content("populargames", $f);
      $self->_box_content("errorist");
    end;
    
    div class => "frontright";
      $self->_box_content("onlinemasters", $f);
      $self->_box_content("instructions");
    end;
  end;
  br style => "clear:both";

  $self->htmlFooter();
}


################################################################################
##  Content Boxes for front page
##  (not in a specific order)
################################################################################
sub _box_content {
  my ($self, $k, $f) = @_;

  #
  # Online Masterservers
  if ($k eq 'onlinemasters') {
    # load server list from database
    my ($list, $np, $p) = $self->dbServerListGet(
      results => 15, 
      sort => "hostname", 
      reverse => 0, 
      gamename => "333networks", 
      updated => 1800
    );

    # print list
    $self->htmlBrowse(
      items    => $list,
      options  => $f,
      total    => $p,
      nextpage => 0,
      pageurl  => "/s/all/all",
      sorturl  => "/s/all/all",
      class    => "frontmasterlist",
      ($p <= 0) ? (footer => sub {Tr;td colspan => 3, class => 'tc2', 'No masterservers found!';end 'tr';}) : (),
      header   => [
          [ '',                     'country' ],
          [ 'Masterserver Address', 'hostname'],
          [ 'Last seen',            'updated' ],
      ],
      row     => sub {
        my($s, $n, $l) = @_;
        Tr $n % 2 ? (class => 's odd') : (class => 's');
          my ($flag, $country) = $self->countryflag($l->{country});
          td class => "tc1 flag", style => "background-image: url(/flag/$flag.svg);", title => $country, '';
          td class => "tc2"; a href => "/$l->{gamename}/$l->{ip}:$l->{hostport}", (split(' ', $l->{hostname}))[0]; end;
          td  $self->timeformat($l->{diff});
        end;
      },
    ); 
    return;
  }

  #
  # Instructions
  if ($k eq 'instructions') {
    div class => "mainbox";
      $self->figurelink("masterserver", "ubrowser2.jpg", "http://333networks.com/instructions");
      h2 "Instructions";      
      p;
        txt "In order to make online games work again after GameSpy ceased all services a lot of online multiplayer games were no longer supported. 333networks provides an alternative masterserver. This masterserver needs to be ";
        span class => "ext", "manually";
        txt " activated in your settings. This can be done by adding one of the following masterserver addresses to your client settings:";
      end;
      ul;
        li "master.333networks.com:28900";
        li "master.errorist.tk:28900";
        #li "master.noccer.de:28900";
        li "master.newbiesplayground.net:28900";
      end;
      p "As player, you can configure your game in the following way: find your configuration file and update your masterserver entries.";
      p;a href => "http://333networks.com/instructions", "[Read the quick instruction here]";end;
    end;
    return;
  }
  
  #
  # Popular games
  if ($k eq 'populargames') {
    # load server list from database
    my($list, $np, $p) = $self->dbGameListGet(results => 15, sort => 'num_total', reverse => 1);
    # print list
    $self->htmlBrowse(
      items    => $list,
      options  => $f,
      total    => $p,
      nextpage => 0,
      pageurl  => "/g/all",
      sorturl  => "/g/all",
      class    => "frontpage",
      ($p <= 0) ? (footer => sub {Tr;td colspan => 3, class => 'tc1', 'No games found.';end 'tr';}) : (),
      header   => [
          [ 'Top 10 popular games', 'description' ],
          [ 'Direct',     'num_uplink'   ],
          [ 'Total',      'num_total'    ],
      ],
      row     => sub {
        my($s, $n, $l) = @_;
        Tr $n % 2 ? (class => 's odd') : (class => 's');
          td class => "tc1 flag"; a href => "/s/$l->{gamename}", $l->{description};end;
          td $l->{num_uplink};
          td $l->{num_total};
        end;
      },
    );
    return;
  }

  #
  # Errorist Forum
  if ($k eq 'errorist') {
    div class => "mainbox";
      $self->figurelink("other", "erroristforum.jpg", "http://forum.errorist.tk");
      h2 "The Errorist Network";
      p "Together with Errorist, we started and share our own forum. This platform is a development corner for UEngine games and the 333networks masterserver + games using it. Visit us at forum.errorist.tk and sign up!";
      p;
        a href => "http://forum.errorist.tk", "[Join the talks!]";
      end;
    end;
    return;
  }
}
1;
