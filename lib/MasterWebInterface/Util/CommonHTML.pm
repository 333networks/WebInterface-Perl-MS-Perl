package MasterWebInterface::Util::CommonHTML;
use strict;
use warnings;
use TUWF ':html';
use Exporter 'import';
our @EXPORT = qw| htmlSearchBox |;

################################################################################
# Search box with first letters
# for games, servers and possibly later on players
################################################################################
sub htmlSearchBox {
  my($self, $sel, $v) = @_;

  fieldset class => 'search';
   p id => 'searchtabs';
    a href => '/g/all', $sel eq 'g' ? (class => 'sel') : (),  'Games';
    a href => '/s/all', $sel eq 's' ? (class => 'sel') : (),  'Servers';
    #a href => '/p/all', $sel eq 'p' ? (class => 'sel') : (),  'Players';
   end;
   input type => 'text', name => 'q', id => 'q', class => 'text', value => $v;
   input type => 'submit', class => 'submit', value =>  'search';
  end 'fieldset';
}

1;
