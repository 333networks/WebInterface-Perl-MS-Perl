package MasterInterface::Handler::ServInfo;
use strict;
use warnings;
use utf8;
use TUWF ':html';
use URI::Escape;
use POSIX 'strftime';
use Exporter 'import';
our @EXPORT = qw| serverError |;

TUWF::register(
  qr{(.[\w]*)/([\.\w]+):(\d+)} => \&show_server,
);

################################################################################
# Display server information
# Verify if game and server (ip:hostport) exist. Display as many available
# values as possible.
# Display error pages if not found or incorrect.
################################################################################
sub show_server {
  # self, gamename, "ip:port"
  my ($self, $gamename, $s_addr, $s_port) = @_;
  
  # break address apart in valid ip, port
  my ($ip,$port) = $self->valid_address($s_addr, $s_port);

  # display an error in case of an invalid IP or port
  unless ($ip && $port) {
    $self->serverError(
      ip   => ($ip ? 0 : 1),
      port => ($port ? 0 : 1),
    ); 
    return;
  }
  
  # select server from database
  my $info = $self->dbGetServerListInfo(
    ip => $ip,
    hostport => $port,
    limit => 1,
  )->[0];  
  
  # either redirect or show error when no info was found
  if (!defined $info) {
    # try if query port was provided instead
    my $attempt = $self->dbGetServerListInfo(
      ip => $ip, 
      port => $port, 
      limit => 1
    )->[0];
    
    # if it exists now, automatically redirect to this page (don't show info here)
    if (defined $attempt && defined $attempt->{hostport}) {
      $self->resRedirect("/$gamename/$ip:$attempt->{hostport}");
      return;
    }
    
    # otherwise, it was not found in the database at all. Notify.
    $self->serverError(db => 1);
    return;
  }
  
  # load additional information if available
  my $details = $self->dbGetServerDetails(id => $info->{id})->[0];
  $info = { %$info, %$details } if $details;

  #
  # generate info page
  #
  $self->htmlHeader(title => $info->{hostname} || "Yet Another Server");
  div class => "mainbox detail";
    div class => "header";
      h1 $info->{hostname} || "Yet Another Server";
    end;
    
    # if no detailed info was found, the server was not updated or 
    # the game is not supported.
    if (!defined $details) {
      div class => 'warning';
        h2 'Detailed information missing!';
        p "Additional information could not be loaded. Either the server was not updated in our database, or detailed information for this game is not yet supported. The information on this page may not be accurate!";
      end;
    }
    
    #
    # Map thumbnail and bot info
    #
    div class => "container";
      div class => "thumbnail";
      
        # find the correct thumbnail, otherwise standard 333 esrb pic
        my $mapfig = "$self->{map_url}/default/333esrb.jpg";
        
        # get prefix and mapname
        my $mapname = lc $info->{mapname};
        my ($pre,$post);
           ($pre,$post) = $mapname =~ /^(DM|CTF\-BT|BT|CTF|DOM|AS|JB|TO|SCR|MH)-(.*)/i if ($info->{gamename} eq "ut");
           ($pre,$post) = $mapname =~ /^(as|ar|coop|coop\d+|ctt|dk|dm|hb|nd)-(.*)/i    if ($info->{gamename} eq "rune");
           ($pre,$post) = $mapname =~ /^(MPDGT|MPS)-(.*)/i                             if ($info->{gamename} eq "postal2");

        # special cases
        $pre = "coop" if ($pre && $pre =~ m/(coop\d+)/i );
        my $prefix = ($pre ? uc $pre : "other");
        
        # if map figure exists, use it
        if (-e "$self->{map_dir}/$info->{gamename}/$prefix/$mapname.jpg") {
          $mapfig = "$self->{map_url}/$info->{gamename}/$prefix/$mapname.jpg";
        }
        
        # if not, game default image
        elsif (-e "$self->{map_dir}/default/$info->{gamename}.jpg") {
          $mapfig = "$self->{map_url}/default/$info->{gamename}.jpg";
        }
      
        img src => $mapfig,
            alt => $mapfig,
            title => ($info->{mapname} || "Unknown");
        span ($info->{maptitle} || ($info->{mapname} || "Unknown"));
      end;
    
      table class => "mapinfo";
      if ($info->{maxplayers}) {
        Tr;
          td class => "wc1", "Players:";
          td;
            txt $info->{numplayers} || 0;
            txt "/";
            txt $info->{maxplayers} || 0;
          end;
        end;
      }
      if ($info->{botskill} && $info->{minplayers}) {
        Tr;
          td "Bots:";
          td;
            txt $info->{minplayers} || 0;
            txt " ";
            txt ($info->{botskill} || "Standard");
            txt " bot"; txt ($info->{minplayers} == 1 ? "" : "s");
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
        th class => "wc1", title => "Server ID: ".$info->{id}, "Server Info"; 
        th ""; 
      end;
      Tr; 
        td "Address:"; 
        td title => $info->{port}, (($info->{ip} || $ip). ":". ($info->{hostport} || $port)); 
      end;
      if ($info->{adminname}) {
        Tr;
          td "Admin:"; 
          td $info->{adminname};
        end;
      }
      Tr; 
        td class => "wc1", "Contact:";
        td;
          if ($info->{adminemail}) {txt $info->{adminemail}} else {
            i; 
              txt "This server has no contact information listed "; 
              a href => "https://ut99.org/viewtopic.php?f=33&t=6660", "[?]"; 
            end;
          }
        end;
      end;
      Tr;
        td class => "wc1", "Location:";
        my ($flag, $country) = $self->countryflag($info->{country} || "");
        td;
          img class => "flag", src => "/flag/$flag.svg";
          txt " ". $country;
        end;
      end;
      Tr; {
        td "Added:";
        my @t = gmtime($info->{addiff});
        my $sig = 0;
        my $diff = "";
        if ($t[5]-70){$diff.=$t[5]-70 ." year".(($t[5]-70==1)?"":"s"); $sig++}
        if ($t[7]){$diff.=($sig?", ":""). $t[7]." day".(($t[7]==1)?"":"s")}
        if ($diff eq "") {$diff = "Less than one day";}
        td $diff." ago (".(strftime "%e %b %Y", gmtime $info->{e_added}).")";}
      end;
      Tr;
        td "Last seen:";
        td;{
          my @t = gmtime($info->{updiff});
          if ($t[5]-70 || $t[7]) {
            # more than 1 day? show date
            span class => "r", (strftime "%e %b %Y", gmtime $info->{e_updated});
          } else {
            # less than 1 day? show "time ago"
            my $diff = "";
            $diff .= ($t[2] ? $t[2]." hour".($t[2]>1?"s, ":", ") : "");
            $diff .= ($t[1] ? $t[1]." minute".($t[1]>1?"s, ":", ") : "");
            $diff .= ($t[0] ? $t[0]." second".($t[0]>1?"s":" ") : "0 seconds");
            $diff .= " ago";
            span $diff;
          }
        end;}
      end;
      Tr;
        td "Flags: ";
        td;
          ($info->{b333ms}      ? span class => "g", "direct uplink, " : span class => "o", "applet or manual, ");
          ($info->{blacklisted} ? span class => "r", "blacklisted, "   : span class => "g", "not blacklisted, ");
          ($info->{password}    ? span class => "y", "passworded"      : span class => "g", "not passworded");
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
        td;
          a href => "/s/$gamename/all", ($info->{description} || $gamename);
        end;
      end;
      if ($info->{gametype}) {
        Tr;
          td "Type:"; 
          td $info->{gametype};
        end;
      }
      if ($info->{gamestyle}) {
        Tr;
          td "Style:"; 
          td $info->{gamestyle};
        end;
      }
      if ($info->{gamever}) {
        Tr;
          td "Version:"; 
          td $info->{gamever};
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
          if (defined $info->{mutators} && $info->{mutators} ne "None") {
            txt $info->{mutators};}
          else {i "This server does not have any mutators listed.";}
        end;
      end;
    end;
    
    table class => "players";
      my $player = $self->dbGetPlayerInfo(server_id => $info->{id});
      my %team = ( 0 => "#e66",
                   1 => "#66e",
                   2 => "#6e6",
                   3 => "#ee6",
                   4 => "#fe6");

      # loop through players and print them in a nicely formatted table with funky colors    
      Tr; 
        th class => "wc1", "Player Info"; 
        th class => "frags", 'Frags'; 
        th class => "mesh", 'Mesh'; 
        th class => "skin", 'Skin'; 
        th class => "ping", 'Ping'; 
      end;
      
      for (my $i=0; defined $player->[$i]->{player}; $i++) {
        # determine teamcolor
        my $teamcolor = "#aaa";
           $teamcolor = $team{$player->[$i]->{team}} if ($player->[$i]->{team} =~ m/^([0-4]|255)$/i);
      
        Tr $i % 2 ? (class => 'odd') : (), style => 'color:'.$teamcolor;
          td class => "wc1",   $player->[$i]->{player} . (($player->[$i]->{ngsecret} && $player->[$i]->{ngsecret} =~ m/^bot$/i) ? " (bot)" : "");
          td class => "frags", $player->[$i]->{frags};
          td class => "mesh",  $player->[$i]->{mesh};
          td class => "skin",  $player->[$i]->{skin};
          td class => "ping",  $player->[$i]->{ping};
        end;
      }
      if (!defined $player->[0]->{player}) { Tr; td colspan => 5; lit '<i>There is no player information available.</i>'; end; end;}
    end;



    #
    # Share options (copy fields)
    #    
    my $url = $self->{url}. "/". $gamename. "/". $info->{ip}. ":". $info->{hostport};
    table class => "shareopts";
      Tr; 
        th class => "wc1", "Share";
        th ""; 
      end;
      Tr;
        td class => "tc1", "Link";
        td class => "tc2";
          input type => 'text', class => 'text', name => 'url', value => $url;
        end;
      end;
      Tr;
        td class => "tc1";
          txt "Json API ";
          a href => "/json", title => "The url to access this server over the 333networks Json API", "*";
        end;
        td class => "tc2";
          input type => 'text', class => 'text', name => 'url', value => $self->{url}. "/json/". $gamename. "/". $info->{ip}. ":". $info->{hostport};
        end;
      end;
      Tr;
        td "Forum Link";
        td;
          textarea type => 'textarea', class => 'text', rows => 3, name => 'paste';
            txt "\[url=$url\]";lit "\n";
            lit "\t";txt $info->{hostname};lit "\n";
            txt "\[/url\]";
          end;
        end;
      end;
      Tr;
        td "HTML Code";
        td;
          textarea type => 'textarea', class => 'text', rows => 3, name => 'paste';
            txt "<a href=\"$url\">";lit "\n";
            lit "\t"; txt $info->{hostname};lit "\n";
            txt "</a>";
          end;
        end;
      end;
    end;

=pod
  Optional information blocks:
  
    #
    # Teams
    #
    table class => "teaminfo";
      Tr; 
        th class => "wc1", "Team Info"; 
        th ""; 
      end;
      Tr;
        td "Balance Teams:";
        td ($info->{balanceteams} ? "Yes" : "No");
      end;
      Tr;
        td "Players Balance Teams:";
        td ($info->{playersbalanceteams} ? "Yes" : "No");
      end;
      Tr;
        td "Friendly Fire:";
        td ($info->{friendlyfire} || "0%");
      end;
      Tr;
        td "Max Teams:";
        td ($info->{maxteams} || 1);
      end;
    end;
    
    #
    # Game Limits
    #
    table class => "limits";
      Tr; 
        th class => "wc1", "Limits"; 
        th ""; 
      end;
      Tr;
        td "Time Limit:";
        td (($info->{timelimit} || 0). ":00 min");
      end;
      Tr;
        td "Score Limit:";
        td ($info->{goalteamscore} || 0);
      end;
      Tr;
        td "Frag Limit:";
        td ($info->{fraglimit} || 0);
      end;
    end;

    div class => "code";
      use Data::Dumper 'Dumper';
      pre;
        txt Dumper [$info, $player];
      end;
    end;

  if ($self->debug) {
    use Data::Dumper 'Dumper';
    lit "<!--\n";
    lit Dumper $info;
    lit Dumper $player;
    lit "\n-->";
  }

=cut
  end; # mainbox details
  $self->htmlFooter;
}

################################################################################
# Display server errors
# Generates error pages in case of faulty gamename, server or other vagueness
################################################################################
sub serverError{
  my ($self, %error) = @_;
  
  $self->htmlHeader(title => "Server Info");
    div class => 'warning';
      h2 'An error occurred while trying to display the server.';
      ul;
        if (!%error) {
          li "Not even the error message works. Please contact the administrator.";}
        if ($error{ip}) {
          li "The provided address is incorrect or does not resolve.";}
        if ($error{port}) {
          li "The provided port is not valid.";}
        if ($error{gamename}) {
          li "The game was not found in our database.";}
        if ($error{db}) {
          li "The server was not found in our database.";}
      end;
    end;
  $self->htmlFooter;
}

1;
