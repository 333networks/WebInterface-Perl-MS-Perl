#!/usr/bin/perl
package MasterWebInterface;
use strict;
use warnings;
use Cwd 'abs_path';

our $ROOT;
BEGIN { ($ROOT = abs_path $0) =~ s{/util/masterwebinterface.pl$}{}; }
use lib $ROOT.'/lib';
use TUWF;

our(%O, %S, @login);
require "$ROOT/data/webinterface-config.pl";

#add %S from web-config.pl to OBJ
$TUWF::OBJ->{$_} = $S{$_} for (keys %S);

# TUWF options
TUWF::set(
  logfile               => "$ROOT/log/MasterWebInterface-TUWF.log",
  mail_from             => '<noreply@333networks.com>',
  db_login              => ['dbi:Pg:dbname=devmasterserver', 'unrealmaster', 'unrealmasterpassword'],
  validate_templates => { # input templates
    page  => { template => 'uint', max => 1000 },
  },
  xml_pretty            => 0,
  log_queries           => 1,
  debug                 => 1,
);

# load master page libs
TUWF::load_recursive('MasterWebInterface::Handler',
                     'MasterWebInterface::Util',
                     'MasterWebInterface::Database::Pg',
                     #'MasterWebInterface::Database::sqlite',
                    ); # Do not forget to choose the database type here!
#and let's roll!
TUWF::run();
