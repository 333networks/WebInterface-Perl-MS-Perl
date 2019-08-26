# MasterServer-WebInterface

Website for the 333networks MasterServer implementation in Perl.

=========

# DESCRIPTION
  
  This repository contains software for a web interface to display information 
  obtained by the 333networks MasterServer package for the support of various
  legacy games. The software was written Darkelarious to soften the effects of 
  GameSpy (GameSpy Industries, Inc.) shutting down their masterserver service.

  A masterserver is a program that maintains a list of online game servers and 
  presents this list to clients (gamers, players) who request the list of game 
  addresses. The 333networks Masterserver is a software framework that allows 
  gamers/players to browse online games.
  
  More information about the masterserver and variations on the protocol by
  333networks can be found online at 
        http://333networks.com/masterserver
        http://wiki.333networks.com/index.php/MasterServer

# AUTHOR
  Darkelarious
  http://333networks.com
  darkelarious@333networks.com

# REQUIREMENTS
  - Apache/httpd
  - Postgresql, MySQL or SQLite3
  - Perl 5.10 or above
  - The following CPAN modules:
      DBI
      DBD::Pg / DBD::SQLite / DBD::mysql
      IP::Country::Fast
      Image::Size
      TUWF (http://dev.yorhel.nl/tuwf)

# INSTALL

  THE MASTER SERVER IS WRITTEN ON LINUX. IF YOU WANT TO RUN THE SOFTWARE IN 
  MICROSOFT WINDOWS OR APPLE OSX, IT MAY NOT WORK WITHOUT MODIFICATIONS.
  
  This repository consists of Perl modules and is run by a http deamon. First,
  the MasterServer-Perl repository should be installed and configured in order
  to run this web interface. The contents of this repository can be extracted
  in the same root folder as MasterServer-Perl.
  
# CONFIGURATION

  The 333networks masterserver interface comes with options. These options are 
  found in configuration file "data/webinterface-config.pl". Comments in the 
  file give a brief description. Below, the configuration is discussed in 
  further detail.
  
  Database login information
  
  The masterserver interface supports different database types. This must be the
  same database (and type) as you specified in your MasterServer-Perl config.
  
  # postgresql
  db_login  => ['dbi:Pg:dbname=masterserver', 'user', 'password'],

  # sqlite
  db_login  => ["dbi:SQLite:dbname=$ROOT/data/masterserver.db",'',''], 
  
  You also need to (un)comment the right database module in the 
  masterwebinterface.pl file to load the correct driver.
  
  Apache settings
  
  LoadModule rewrite_module modules/mod_rewrite.so
  AddHandler cgi-script .cgi .pl
  
  Vhost configuration for the Web Interface (assuming you extracted it in the
  same folder as your MasterServer-Perl installation):
    
  #
  # Master Web Interface
  #
  <VirtualHost *:80>
    ServerAdmin master@yourdomain.com
    ServerName  master.yourdomain.com

    DocumentRoot "/server/MasterServer-Perl/s"
    AddHandler cgi-script .pl

    RewriteEngine On
    RewriteCond "%{DOCUMENT_ROOT}/%{REQUEST_URI}" !-s
    RewriteRule ^/ /masterwebinterface.pl

    ErrorLog  /server/MasterServer-Perl/log/MasterWebInterface-Error.log
    CustomLog /server/MasterServer-Perl/log/MasterWebInterface-Access.log combined

    <Directory "/server/MasterServer-Perl/s">
        Options +FollowSymLinks +ExecCGI
        AllowOverride None
        Require all granted
    </Directory>
  </VirtualHost>

# KNOWN ISSUES
  There are a few known issues that will be resolved in future versions. The
  following issues are listed and do not need to be reported.
  
  This README file does not describe all possible configuration options. There 
  is an initiative to write the webinterface documentation in a single document
  that is focused on all options and recommended values. For now, use your best
  guess.
  
  There are no textures, map thumbnails and/or nice steals included in this 
  repository. All styles, textures, increasingly growing amounts of map thumbs
  and game icons are located at another repository on git.333networks.com and
  are available for all supported packages.
    
# COPYING
  See COPYING file
