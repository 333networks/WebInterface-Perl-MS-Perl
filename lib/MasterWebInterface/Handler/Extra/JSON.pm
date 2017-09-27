package MasterWebInterface::Handler::Extra::JSON;
use strict;
use TUWF ':html';
use Exporter 'import';
use JSON;

TUWF::register(
  qr{json/(.[\w]*)}                 => \&serverlist_json,
  qr{json/(.[\w]*)/(all|[0a-z])}    => \&serverlist_json,
  qr{json/(.[\w]*)/([\.\w]+):(\d+)} => \&json_serverinfo,
  qr{json}                          => \&json_docs,
);

################################################################################
# LIST SERVERS
# Generate a list of selected games in the database per game (arg: gamename)
# Same as &serverlist, but with json output. 
################################################################################
sub serverlist_json {
  my($self, $gamename, $char) = @_;

  # default list if nothing defined
  $char = "all" unless $char;

  # process additional query information, such as order, sorting, page, etc
  my $f = $self->formValidate(
    { get => 'p', required => 0, default => 1,   template => 'page' },
    { get => 'r', required => 0, default => 100, template => 'page' },
    { get => 'q', required => 0, default => '',  maxlength => 90 },
  );
  return $self->resNotFound if $f->{_err};

  # load server list from database
  my($list, $np, $p) = $self->dbServerListGet(
    reverse => $f->{o} eq 'd',
    $char ne 'all' ? ( firstchar => $char ) : (),
    results => $f->{r},
    search => $f->{q},
    gamename => $gamename,
    page => $f->{p},
    filter => 1,
  );

  # return json data as the response
  my $json_data = encode_json [$list, {total => $p}];
  print { $self->resFd() } $json_data;

  # set content type and allow off-domain access (for example jQuery)
  $self->resHeader("Access-Control-Allow-Origin", "*");
  $self->resHeader("Content-Type", "application/json; charset=UTF-8");
}

################################################################################
# Server Info
# Show server info for an individual server
# Same as &server_info, but with json output. 
# returns "error:1" if errors occurred
################################################################################
sub json_serverinfo {
  my ($self, $gamename, $s_addr, $s_port) = @_;
  
  # break address apart in valid ip, port
  my ($ip,$port) = $self->valid_address($s_addr, $s_port);
  
  # select server from database
  my $info = $self->dbGetServerListInfo(
    ip => $ip,
    hostport => $port,
    limit => 1,
  )->[0] if ($ip && $port);

  # display an error in case of an invalid IP or port
  unless ($ip && $port && $info) {
    my %err = (error => 1);
    my $e = \%err;
    my $json_data = encode_json $e;
    my $json_data_size = keys %$e;

    # return json data as the response
   	print { $self->resFd() } $json_data;

    # set content type at the end
    $self->resHeader("Access-Control-Allow-Origin", "*");
    $self->resHeader("Content-Type", "application/json; charset=UTF-8");
    return;
  }

  # load additional information if available
  my $details = $self->dbGetServerDetails(id => $info->{id})->[0];
  $info = { %$info, %$details } if $details;
  my $json_data = encode_json $info;
  my $json_data_size = keys %$info;

  # return json data as the response
 	print { $self->resFd() } $json_data;

  # set content type and allow off-domain access (for example jQuery)
  $self->resHeader("Access-Control-Allow-Origin", "*");
  $self->resHeader("Content-Type", "application/json; charset=UTF-8");
}


################################################################################
# Json Documentation
# Minimalistic documentation about the JSON API
################################################################################
sub json_docs {
  my $self = shift;
  $self->htmlHeader(title => "JSON API");
  div class => "mainbox";
    div class => "header";
      h1 "Json API";
      p class => "alttitle", "On this page you can find documentation about the 333networks masterserver JSON API.";
    end;
    
    p "333networks has a JSON API. With this API, it is possible to obtain server lists and specific server information for your own banners, ubrowser or other application.";
    
    h2 "Permission & Terms of Use";
    p;
      txt "In addition to our ";
      a href => "/disclaimer", "Terms of Use";
      txt ", the following permissions and conditions are in effect: ";
    end;
    p "You are allowed to access our API with any application and/or script, self-made or not, to obtain our server lists and server information on the condition that somewhere, anywhere in your application or script you mention that the information is obtained from 333networks.";
    p "You are not allowed to flood the API with requests or query our API continuously or with a short interval. If you draw too much network traffic from 333networks, we consider this flooding and will terminate your ability to query our API.";
    p "Intended use: use the serverlist request to get show a list of all servers. After loading the list, your visitors/users can select a single server to display detailed information. Do NOT use the serverlist to immediately show detailed information for ALL servers, this causes a ludicrous amount of information requests and will get you excluded from our API.";
    
    h2 "Serverlist request";
    p "The JSON API consists of two functions to query for information. Both methods occur over HTTP and are presented as JSON data. The first method returns a list of servers and can be manipulated by gamename, first letter and number of results. 333networks applies the following regex to process your request:";
    
    div class => "code";
      ul;
        li "$self->{url}/json/(.[\w]*)";
        li "$self->{url}/json/(.[\w]*)/(all|[0a-z])";
      end;
    end;
    
    p;
      txt "In this regex, ";
      span class => "code", "(.[\w]*)";
      txt " refers to the ";
      span class => "ext", "gamename";
      txt ". This is the abbreviation that every game specifies in their masterserver protocol. A comprehensive list of gamenames is found on the ";
      a href => "/g/all", "games";
      txt " page. The request can be augmented with a prefix of the ";
      span class => "ext", "first letter";
      txt " of the server. For example, specifying the ";
      span class => "code", "a";
      txt " will result in all server names starting with an \"a\" at the start of the name being returned.";
    end;
    
    p;
      txt "It is also possible to provide ";
      span class => "code", "GET";
      txt " information in the url. Allowed options are:";
    end;
    
    ul;
      li; span class => "code", "r"; txt " - number of results. Defaults to 50 if not specified. Minimum 1, maximum 1000."; end;
      li; span class => "code", "p"; txt " - page. Show the specified page with results. Total number of entries is included in the result."; end;
      li; span class => "code", "q"; txt " - search query. Identical to the search query on the "; a href => "/servers", "servers"; txt " page. Maximum query length is 90 characters."; end;
    end;

    h3 "Request:";    
    p;
      txt "The following examples have different outcomes. In the first example, we request a serverlist of ";
      span class => "code", "all";
      txt " servers, regardless of type and/or name. The second example requests only servers of the game ";
      span class => "code", "Unreal"; 
      txt " that start with the letter ";
      span class => "code", "a";
      txt ". In the last example, we request a serverlist with the gamename ";
      span class => "code", "333networks";
      txt ", with only ";
      span class => "code", "2";
      txt " results per page, page ";
      span class => "code", "1";
      txt " and with the search word ";
      span class => "code", "master";
      txt ".";
    end;
    
    div class => "code";
      ul;
        li;
          txt "$self->{url}/json/";
          span class => "ext", "all";
        end;
        li;
          txt "$self->{url}/json/";
          span class => "ext", "unreal";
          txt "/";
          span class => "ext", "a";
        end;
        li;
          txt "$self->{url}/json/";
          span class => "ext", "333networks";
          txt "?r=";
          span class => "ext", "2";
          txt "&p=";
          span class => "ext", "1";
          txt "&q=";
          span class => "ext", "master";
        end;
      end;
    end;
    
    h3 "Result:";
    p "The API returns JSON data in the following format, using the third request as an example. This is example data and may vary from what you receive when performing the same query.";
    div class => "code";
    pre '[
  [
    {
      "gametype":"MasterServer",
      "description":"333networks MasterServer (Synchronization Protocol)",
      "hostport":28905,
      "updated":"1506087218",
      "hostname":"dev.333networks.com (333networks Development MasterServer)",
      "maxplayers":2965,
      "country":"NL",
      "mapname":"333networks",
      "added":"1500485970.98186",
      "numplayers":20,
      "gamename":"333networks",
      "diff":"82",
      "id":869,
      "ip":"84.83.176.234",
      "maptitle":null
    },
    {
      "diff":"102",
      "id":870,
      "gamename":"333networks",
      "numplayers":21,
      "added":"1500485971.17096",
      "maptitle":null,"ip":"84.83.176.234",
      "hostname":"master.333networks.com (333networks Main MasterServer)",
      "updated":"1506087198",
      "description":"333networks MasterServer (Synchronization Protocol)",
      "hostport":28900,
      "gametype":"MasterServer",
      "mapname":null,"country":"NL",
      "maxplayers":2965
    }
  ],
  {"total":"3"}
]';
    end;
    
    p;
      txt "The result contains an array of server entries and the ";
      span class => "code", "total";
      txt " amount of entries. In this case, that is ";
      span class => "code", "2";
      txt " entries listed and ";
      span class => "code", "3"; 
      txt " total entries, implying that there is one more server not shown or on a next page. With the specified number of results specified by the user and the total amount of servers provided by the API, you can calculate how many pages there are to be specified. Every server entry has a number of unsorted keywords. The available keywords are:";
    end;
    
    ul;
      li; span class => "code", "id"; txt " - server ID in our database"; end;
      li; span class => "code", "ip"; txt " - IPv4 address"; end;
      li; span class => "code", "hostport"; txt " - hostport to join the game. This port is also used to query specific server information (read more below)"; end;
      li; span class => "code", "hostname"; txt " - name of the server"; end;
      li; span class => "code", "gamename"; txt " - gamename of the server"; end;
      li; span class => "code", "description"; txt " - gamename of the server as comprehensible game title"; end;
      li; span class => "code", "country"; txt " - 2-letter country code where the server is hosted"; end;
      li; span class => "code", "numplayers"; txt " - current number of players"; end;
      li; span class => "code", "maxplayers"; txt " - maximum number of players"; end;
      li; span class => "code", "mapname"; txt " - filename of current map"; end;
      li; span class => "code", "maptitle"; txt " - title or description of current map"; end;
      li; span class => "code", "gametype"; txt " - type of game: capture the flag, deathmatch, etc"; end;
      li; span class => "code", "added"; txt " - date that the server was added to our database"; end;
      li; span class => "code", "updated"; txt " - date that the server was updated in our database"; end;
      li; span class => "code", "diff"; txt " - amount of seconds since this server was updated in our database"; end;
    end;
    p "There are more keywords available for the individual servers. Detailed information about a server is obtained with the Server Information request as described below.";

    h2 "Server Information request";
    p "Your application or script can also request detailed information for a single server. This is done in a similar way as requesting a server list. The following general regex is used by 333networks:";
    div class => "code";
      ul;
        li "$self->{url}/json/(.[\w]*)/([\.\w]+):(\d+)";
      end;
    end;
    
    p;
      txt "This restricts requests to the correct url with a ";
      span class => "code", "gamename";
      txt ", an ";
      span class => "ext", "IP address";
      txt " or ";
      span class => "ext", "domain name";
      txt " and a ";
      span class => "ext", "decimal number";
      txt ". There are no additional query options or GET options. It is possible that the gamename specified does not match the ";
      txt "gamename";
      txt " as stored in our database. The result will include the gamename that was specified in our database.";
    end;
    
    p "The following two examples both request detailed information by IP address and domain name.";
    h3 "Request:";
    div class => "code";
      ul;
        li;
          txt "$self->{url}/json/";
          span class => "ext", "333networks";
          txt "/";
          span class => "ext", "84.83.176.234";
          txt ":";
          span class => "ext", "28900";
        end;
        li;
          txt "$self->{url}/json/";
          span class => "ext", "333networks";
          txt "/";
          span class => "ext", "master.333networks.com";
          txt ":";
          span class => "ext", "28900";
        end;
      end;
    end;
    
    h3 "Result:";
    p "The API returns JSON data in the following format, using the requests above as an example. This is example data and may vary from what you receive when performing the same query.";
    div class => "code";
    pre '{
  "beacon":"2017-09-22 16:49:18+02",
  "updated":"2017-09-22 16:49:18+02",
  "numplayers":21,
  "country":"NL",
  "hostport":28900,
  "added":"2017-07-19 19:39:31.170957+02",
  "maxplayers":2965,
  "gamename":"333networks",
  "gamever":"MS-perl 2.3.1",
  "hostname":"master.333networks.com (333networks Main MasterServer)",
  "friendlyfire":null,
  "listenserver":null,
  "updiff":"48",
  "adminname":"Darkelarious",
  "minplayers":0,
  "mutators":"333networks synchronization, master applet synchronization",
  "mapname":null,
  "maxteams":null,
  "fraglimit":null,
  "blacklisted":0,
  "playersbalanceteams":null,
  "ip":"84.83.176.234",
  "minnetver":null,
  "maptitle":null,
  "port":27900,
  "password":null,
  "b333ms":1,
  "botskill":null,
  "server_id":870,
  "adminemail":"info@333networks.com",
  "id":870,
  "gametype":"MasterServer",
  "gamestyle":null,
  "balanceteams":null,
  "changelevels":null,
  "goalteamscore":null,
  "timelimit":null,
  "location":null,
}';
    end;
    p "The result has a single entry of parameters with a number of unsorted keywords. The available keywords are in addition to the keywords specified in the serverlist:";
    ul;
      li; span class => "code", "server_id"; txt " - detailed server ID in our database"; end;
      li; span class => "code", "minnetver"; txt " - minimal required game version to join"; end;
      li; span class => "code", "location"; txt " - geographical area (GameSpy)"; end;
      li; span class => "code", "listenserver"; txt " - dedicated server?"; end;
      li; span class => "code", "adminname"; txt " - server administrator's name"; end;
      li; span class => "code", "adminemail"; txt " - server administrator's contact information"; end;
      li; span class => "code", "password"; txt " - passworded/locked server"; end;
      li; span class => "code", "gamestyle"; txt " - in-game playing style"; end;
      li; span class => "code", "changelevels"; txt " - automatically change levels after match end"; end;
      li; span class => "code", "minplayers"; txt " - number of bots"; end;
      li; span class => "code", "botskill"; txt " - skill level of bots"; end;
      li; span class => "code", "balanceteams"; txt " - team balancing on join"; end;
      li; span class => "code", "playersbalanceteams"; txt " - players can toggle automatic team balancing"; end;
      li; span class => "code", "friendlyfire"; txt " - friendly fire rate"; end;
      li; span class => "code", "maxteams"; txt " - maximum number of teams"; end;
      li; span class => "code", "timelimit"; txt " - time limit per match"; end;
      li; span class => "code", "goalteamscore"; txt " - score limit per match"; end;
      li; span class => "code", "fraglimit"; txt " - score limit per deathmatch"; end;
      li; span class => "code", "mutators"; txt " - comma-separated mutator/mod list"; end;
      li; span class => "code", "b333ms"; txt " - direct beacon to the masterserver"; end;
      li; span class => "code", "beacon"; txt " - date that the last beacon was received"; end;
      li; span class => "code", "blacklisted"; txt " - server is blacklisted at 333networks"; end;
    end;
    
    h2 "Feedback";
    p;
      txt "We wrote the JSON API with the intention to make the 333networks masterserver data as accessible as possible. If you feel like any functionality is missing or incorrectly shared, do not hesitate to ";
      a href => "/contact", "contact";
      txt " us and to provide feedback. Additionally, we request that you follow the advise on usage as we described under the Terms of Use on top of this page, so we can keep providing this API.";
    end;
    
  end; # mainbox
  $self->htmlFooter(last_change => "Sep 2017");
}

1;
