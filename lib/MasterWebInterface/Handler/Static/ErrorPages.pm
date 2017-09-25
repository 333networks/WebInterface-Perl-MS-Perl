package MasterWebInterface::Handler::Static::ErrorPages;
use strict;
use TUWF ':html';

################################################################################
# TUWF: 
# Set the default error pages for errors
################################################################################
TUWF::set(
  error_400_handler => \&handle400,
  error_404_handler => \&handle404,
  error_405_handler => \&handle405,
  error_413_handler => \&handle413,
  error_500_handler => \&handle500,
);

TUWF::register(
  qr{500}         => sub {die "Process died on purpose"},
  qr{unavailable} => \&handle_unavailable,
  qr{nospam}      => \&nospam,
);

################################################################################
# Catch malformed links that were not replaced by the javascript tool
# Can also be the result of no javascript.
################################################################################
sub nospam {
  my $self = shift;
  $self->htmlHeader(title => 'Go Away!', noindex => 1);

   div class => 'warning';
    h1 'Form Error';
    p 'The form could not be sent. Either you are a robot or you do not have Javascript enabled in your browser.';
   end;

  $self->htmlFooter;
}

################################################################################
# Not yet available
################################################################################
sub handle_unavailable {
  my $self = shift;
  
  $self->htmlHeader(title => 'Function Unavailable');
    div class => 'warning';
      h1 'Function Unavailable';
      p "The function you tried to access was set unavailable. This action is either not written yet, or was disabled by the server administrator. As soon as this function becomes available, it will be announced on the front page.";
    end;
  $self->htmlFooter;
}

################################################################################
# Error 400
################################################################################
sub handle400 {
  my $self = shift;
  
  $self->resStatus(400);
  $self->htmlHeader(title => '400 - Bad Request');
    div class => 'warning';
      h1 '400 - Bad Request';
      p "The server was unable to understand the request and process it.";
    end;
  $self->htmlFooter;
}

################################################################################
# Error 404
# I either screwed up with a link, or the page you are looking for does not 
# exist. A little more content would be nice, and perhaps a funny picture.
################################################################################
sub handle404 {
  my $self = shift;
  
  $self->resStatus(404);
  $self->htmlHeader(title => '404 - Not Found');
    div class => 'warning';
      h1 '404 - Not Found';
      p;
        txt 'It seems the page you were looking for does not exist,';
        br;
        txt 'you may want to try using the menu to find what you are looking for.';
      end;
    end;
  $self->htmlFooter;
}

################################################################################
# Error 405
################################################################################
sub handle405 {
  my $self = shift;
  
  $self->resStatus(405);
  $self->htmlHeader(title => '405 - Method Not Allowed');
    div class => 'warning';
      h1 '405 - Method Not Allowed';
      p "The submitted method is not allowed.";
    end;
  $self->htmlFooter;
}

################################################################################
# Error 413
################################################################################
sub handle413 {
  my $self = shift;
  
  $self->resStatus(413);
  $self->htmlHeader(title => '413 - Request Entity Too Large');
    div class => 'warning';
      h1 '413 - Request Entity Too Large';
      p "The requested entity contains too many bytes.";
    end;
  $self->htmlFooter;
}

################################################################################
# Error 500
# Internal server error, most likely due to a database freezing/being busy
################################################################################
sub handle500 {
  my($self, $error) = @_;
  
  $self->resStatus(500);
  $self->htmlHeader(title => '500 - Internal Server Error');
    div class => 'warning';
      h1 '500 - Internal Server Error';
      p 'Something went wrong on our side. The problem was logged and will be fixed shortly. Please try again later.';
      
      if ($self->debug) {
        div class => "code";
          pre $error;
        end;
      }
    end;
  $self->htmlFooter;
}

1;
