package MasterWebInterface::Util::Layout;
use strict;
use warnings;
use TUWF ':html';
use Exporter 'import';
our @EXPORT = qw| htmlHeader htmlFooter |;

################################################################################
# htmlHeader
# options: title, noindex
################################################################################
sub htmlHeader {
  my($self, %o) = @_;

  html lang => "en";
    head;
      title "$o{title} :: $self->{site_title}";
      Link rel => 'shortcut icon', href => "$self->{url}/favicon.ico", type => 'image/x-icon';
      Link rel => 'stylesheet', href => "$self->{url}/style/$self->{style}/style.css", type => "text/css", media => "all";
      meta name => "google-site-verification", content => "tkhIW87EwqNKSGEumMbK-O3vqhwaANWbNxkdLBDGZvI";end;
      meta name => 'robots', content => 'noindex,nofollow,nosnippet,noodp,noarchive,noimageindex';end; #FIXME set proper robots params
      script type => 'text/javascript', src => "$self->{url}/interface-scripts.js", '';
    end; # head
    
    body;
      div class => 'nav';
        ul;
          li; a href => "/",           "home";    end;
          li; a href => "/g/all",      "games";   end;
          li; a href => "/s/all",      "servers"; end;
        end;
      end;
    
      div id => "body";
        # start the page content with a header logo box
        div class => "titlebox";
        end;
}

################################################################################
# htmlFooter
# options: last edited (not shown)
# General html layout header (bottom)
################################################################################
sub htmlFooter {
  my $self = shift;
      br style => "clear:both";
      
        div id => 'footer';
          txt "$self->{site_title} | Powered by ";
          a href => "http://333networks.com", "333networks";
          txt " & ";
          a href => "http://dev.yorhel.nl/tuwf", "TUWF";
        end;
      end 'div'; # body
    end 'body';
  end 'html';
}

1;
