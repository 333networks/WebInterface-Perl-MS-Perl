package MasterWebInterface::Handler::Tools::Version;
use strict;
use warnings;
use TUWF ':html';

TUWF::register(
  qr{version}, \&version,
);

sub version {
  my $self = shift;
  $self->htmlHeader(title => 'Version information', noindex => 1);

  div class => "mainbox contact";
    div class => "header";
      h1 "Version Information";
      p class => "alttitle", "";
    end;
        
    # version and author information
    #
    # You are not allowed to modify these variables without making (significant)
    # alterations to the source code of this master server program. Only changing
    # these fields does not count as a significant alteration.
    #
    # -- addition to the LICENCE, you are only allowed to modify these lines
    # if you send Darkelarious a postcard or (e)mail with your compliments.
    #

    p "This MasterServer Interface has the following version information:";
    table;
      Tr; td "build_type";    td "333networks Masterserver Web Interface ";end;
      Tr; td "build_version"; td "3.0.1";end;
      Tr; td "build_date";    td "2017-09-27";end;
      Tr; td "build_author";  td "Darkelarious, darkelarious\@333networks.com";end;
    end;    
    
    p "This MasterServer Interface is compatible since the following MasterServer type(s):";
    table;
      Tr; td "build_type";    td "333networks Masterserver-Perl";end;
      Tr; td "build_version"; td "2.4.1";end;
      Tr; td "build_date";    td "2017-09-25";end;
      Tr; td "build_author";  td "Darkelarious, darkelarious\@333networks.com";end;
    end;    
    
  end;
}

1;

