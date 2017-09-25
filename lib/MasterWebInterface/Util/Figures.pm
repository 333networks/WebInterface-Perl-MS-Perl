package MasterWebInterface::Util::Figures;
use strict;
use warnings;
use TUWF ':html';
use Exporter 'import';
use Image::Size;
our @EXPORT = qw| figure figurelink |;

################################################################################
# Load image in Yorhel's IV.
################################################################################
sub figure {
  my ($self, $d, $f, $s) = @_;
  my $extra_css = (defined($s)) ? "style=\"$s\"" : "";
  my ($w, $h) = imgsize("$self->{img_path}/$d/$f");
    # make a link and show a thumbnail if exists, else photo itself
    if (-e "$self->{img_path}/t/$f") { 
      lit "<a rel=\"iv:$w"."x"."$h\" href=\"/img/$d/$f\"><img $extra_css src=\"/img/t/$f\" alt=\"$f\"/></a> "
    }
    else{
      lit "<a rel=\"iv:$w"."x"."$h\" href=\"/img/$d/$f\"><img $extra_css src=\"/img/$d/$f\" alt=\"$f\"/></a> "}
}

################################################################################
# Have a picture $f link to destination $dest -- wrapper function
################################################################################
sub figurelink {
  my ($self, $d, $f, $dest) = @_;
    # make a link and show a thumbnail if exists, else photo itself
    if (-e "$self->{img_path}/t/$f") { 
      lit "<a href=\"$dest\"><img src=\"/img/t/$f\" alt=\"$f\"/></a> "
    }
    else{
      lit "<a href=\"$dest\"><img src=\"/img/$d/$f\" alt=\"$f\"/></a> "}
}


1;
