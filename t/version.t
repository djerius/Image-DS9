use strict;
use warnings;

use Test::More;
use Image::DS9;

BEGIN { plan( 'no_plan' ) ;}

require 't/common.pl';


my $ds9 = start_up();

eval {
  $ds9->version();
};
ok ( ! $@, 'version' );
