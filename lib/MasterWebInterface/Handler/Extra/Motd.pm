package MasterInterface::Handler::Extra::Motd;
use strict;
use warnings;
use utf8;
use TUWF ':html';
use Exporter 'import';
our @EXPORT = qw| motd_static |;

#
# Message of the Day for things like the JSON API or updateserver page
#
sub motd_static {
  my ($self, $gamedesc) = @_;
  
  return "<h1>Welcome</h1>
  <p>This is the renewed 333networks UBrowser for $gamedesc. The UBrowser is a web version of the Multiplayer Games browser similar to the one found ingame. We went through great efforts to give the UBrowser the same look and feel as you are used to. We hope you will enjoy it as much as we enjoyed making it!</p>
  
  <h2>About 333networks</h2>
  <p>333networks is a non-profit development group that hosts and develops support for legacy games. With a number of international volunteers, 333networks developed an alternative, open-source masterserver after the largest commercial alternative GameSpy<sup style=\"font-size:tiny\"><a href=\"http://www.gamasutra.com/view/news/214700/GameSpy_ceasing_all_hosted_services_this_May.php\">[1]</a></sup> announced the shutdown of their services in 2014. The 333networks masterserver is an open-source initiative by Darkelarious, implemented in the Perl language and uses a database to keep a record of a unique list of gameservers for a variety of supported games.</p>
     
  <p>Thanks to the efforts of various communities and many others, 333networks grew to a large website network with multiple masterservers (<a href=\"http://master.333networks.com\">333networks</a>, <a href=\"http://master.errorist.tk\">errorist</a>, <a href=\"http://master.oldunreal.com\">oldunreal</a>, <a href=\"http://master.newbiesplayground.net\">newbiesplayground</a>), a <a href=\"http://git.333networks.com\">git repository</a>, our own <a href=\"http://forum.errorist.tk\">forum</a>, <a href=\"http://wiki.333networks.com\">wiki</a> and countless happy communities.</p>
  
  <p>We continue to improve ourselves with improved masterserver software, more reliable and industrial level software robustness, redundancies, documentation and various expansions on existing themes. This has always been and will continue to be a hobby for Darkelarious and the countless people who helped 333networks grow to where it is today.</p>
  
  <p>Over the years we went from a simple website to a major player in sustaining multiplayer games. We still have a long way to go as there are hundreds of publishers and titles that rely on their individual communities. As the days go by, more and more people find out about 333networks and ask for help with support for their game, and we will try our best to extend our coverage for these games too. So we keep going. We expand our website. We extend our masterserver. And we enjoy it.</p>
  
  <p>Do you want to become a volunteer too? Or perhaps consider <a href=\"http://333networks.com/donate\">a donation</a>?</p>";
}
1;
