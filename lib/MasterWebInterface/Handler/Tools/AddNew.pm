package MasterWebInterface::Handler::Tools::AddNew;
use strict;
use warnings;
use Encode;
use Socket;
use IP::Country::Fast;
use TUWF ':html';

TUWF::register(
  qr{new}                       => \&addnewserver,
  qr{new/([\.\w]+):(\d+)/(\d+)} => \&valnewserver,
);

################################################################################
# Helper page to add server addresses to the masterserver manually
# Uses the valnewserver page/function to validate an active server.
################################################################################
sub addnewserver {
  my $self = shift;
  $self->htmlHeader(title => "Add a new server");
  
  div class => "mainbox detail";
    div class => "header";
      h1 "Manually add a server";
      p class => "alttitle", "333networks allows you to add supported servers manually. On this page is explained how to add your server to our masterserver.";
    end;
  
    p "You can add your server to our site in two ways:";
    ol;
      li;
        txt "Follow the instructions on the ";
        a href => "/masterserver", "MasterServer";
        txt " page. This also allows other players to see your server online.";
      end;
      li "Follow the instructions below. This allows you to share links to your server page.";
    end;
    
    p;
      txt "To link to your serverstatus, fill in your gameserver's IP and your gameserver's queryport, usually the game port +1. If your server does not show up, check for typos and verify that your firewall is not blocking your server. Your ip is ";
      span class => "ext", $ENV{'REMOTE_ADDR'};
      txt ".";
    end;
    
    table class => "shareopts new";
      Tr;
        td "IP address:";
        td; input type => "text", class => "text", id => "ip", value => $ENV{'REMOTE_ADDR'}; end;
      end;
      Tr;
        td "Query port (game port + 1):";
        td; input type => "text", class => "text", id => "port", value => "7778"; end;
      end;
      Tr;
        td "";
        td; input type => "submit", class => "submit", value => "Search Server", onclick => "QueryLink()"; end;
      end;
    end;

    p id => "newlink", class => "ext"; 
      txt "Please enter the server's ip and port in the fields above."; 
    end;

  end;
  
  div id => "validate";
  end;

  $self->htmlFooter;
}


################################################################################
# Query and validate a manually added server.
# Arguments passed on via javascript (unsafe)
# Random number prevents some browsers from caching the request and also
# prevents the /gamename/ip:port regex from catching this function/page.
################################################################################
sub valnewserver {
  my ($self, $s_addr, $s_port, $s_rand) = @_;
  my ($ip,$port) = $self->valid_address($s_addr, $s_port);
  
  # return "invalid" if no valid ip/port
  if (!$ip || !$port){die "invalid";return;}
  
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # DANGEROUS CODE: DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Query the game server here on the spot. This may cause timeouts/errors with 
  # slow or unresponsive servers. Will generate an error in the browser if so.
  #
  # TODO: consider safer code for this part.
  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  # prepare target
  my $qaddr = sockaddr_in($port, inet_aton($ip) );
  my ($data, $buf) = ("","");

  eval {
    # return error stats on time-out
    local $SIG{ALRM} = sub {die "timeout"};
    
    alarm 2;
      socket(SERVER, PF_INET, SOCK_DGRAM, getprotobyname("udp")) or die "timeout";
      connect(SERVER, $qaddr);
      send(SERVER, "\\status\\", 0, $qaddr);
      
      #receive server info
      while($data !~ /\\final\\/) {
        recv(SERVER, $data, 0xFFFF, 0);
        $buf .= $data;
      }
      shutdown(SERVER, 2);
    alarm 0;
  };
  
  # turn buffer into hashref
  my @a = split /\\/, encode('UTF-8', $buf || "");
  shift @a;
  my %h = (@a, (scalar @a % 2 == 1) ? "dummy" : () );
     %h = map { lc $_ => $h{$_} } keys %h;  
  my $r = \%h;
  
  # any text received?
  # check for some random, supposedly existing tags like gamename, gamever
  if ($r->{gamename} || $r->{gamever}) {
    div class => "mainbox detail";
      div class => "header";
        h1 $r->{hostname} || "Unnamed Server";
      end;
      
      div class => "container";
        div class => "thumbnail";
        
          # find the correct thumbnail, otherwise standard 333 esrb pic
          my $mapfig = "$self->{map_url}/default/333esrb.jpg";
          
          # get prefix and mapname
          my $mapname = lc $r->{mapname};
          my ($pre,$post) = $mapname =~ /^(DM|CTF\-BT|BT|CTF|DOM|AS|JB|TO|SCR|MH)-(.*)/i;
          my $prefix = ($pre ? uc $pre : "other");        
          
          # if map figure exists, use it
          if (-e "$self->{map_dir}/$r->{gamename}/$prefix/$mapname.jpg") {
            $mapfig = "$self->{map_url}/$r->{gamename}/$prefix/$mapname.jpg";
          }
          
          # if not, game default image
          elsif (-e "$self->{map_dir}/default/$r->{gamename}.jpg") {
            $mapfig = "$self->{map_url}/default/$r->{gamename}.jpg";
          }
        
          img src => $mapfig,
              alt => $mapfig,
              title => ($r->{mapname} || "Unknown");
          span ($r->{maptitle} || "Unknown");
        end;
      
        table class => "mapinfo";
        if ($r->{maxplayers}) {
          Tr;
            td class => "wc1", "Players:";
            td;
              txt $r->{numplayers} || 0;
              txt "/";
              txt $r->{maxplayers} || 0;
            end;
          end;
        }
        if ($r->{botskill} && $r->{minplayers}) {
          Tr;
            td "Bots:";
            td;
              txt $r->{minplayers} || 0;
              txt " ";
              txt ($r->{botskill} || "Standard");
              txt " bot"; txt ($r->{minplayers} == 1 ? "" : "s");
            end;
          end;
        }
        end;
      end; # container
      
      # 
      # Specific server entry information
      #
      table class => "serverinfo";
        Tr; 
          th class => "wc1", "Server Info"; 
          th ""; 
        end;
        Tr; 
          td "Address:"; 
          td title => $r->{port}, (($r->{ip} || $ip). ":". ($r->{hostport} || $port)); 
        end;
        if ($r->{adminname}) {
          Tr;
            td "Admin:"; 
            td $r->{adminname};
          end;
        }
        Tr; 
          td class => "wc1", "Contact:";
          td;
            if ($r->{adminemail}) {txt $r->{adminemail}}
          end;
        end;
        Tr;
          td class => "wc1", "Location:";
          my $reg = IP::Country::Fast->new();
          my ($flag, $country) = $self->countryflag($reg->inet_atocc($ip) || "");
          td;
            img class => "flag", src => "/flag/$flag.svg";
            txt " ". $country;
          end;
        end;
      end;
      
      #
      # Specific game and version information
      #
      table class => "gameinfo";
        Tr; 
          th class => "wc1", "Game Info"; 
          th ""; 
        end;
        Tr;
          td "Game:"; 
          td $self->dbGetGameDesc($r->{gamename}) || "unknown game";
        end;
        if ($r->{gametype}) {
          Tr;
            td "Type:"; 
            td $r->{gametype};
          end;
        }
        if ($r->{gamestyle}) {
          Tr;
            td "Style:"; 
            td $r->{gamestyle};
          end;
        }
        if ($r->{gamever}) {
          Tr;
            td "Version:"; 
            td $r->{gamever};
          end;
        }
      end;
      
      #
      # Mutator list
      #
      table class => "mutators";
        Tr;
          th "Mutators";
        end;
        Tr;
          td;
            if (defined $r->{mutators}) {
              txt $r->{mutators};}
            else {i "This server does not have any mutators listed.";}
          end;
        end;
      end;
      
      # add this server to the list of pending IPs if it does not exist in the db already
      p class => "ext", ( $self->dbAddServer(ip => $ip, port => $port) ? "The server was added to the database." : "The server already exists in the database." );
    end; # mainbox detail

  }
  else {
    # else return "invalid" to make AJAX understand that the query failed.
    txt "invalid";
  }
}

1;

