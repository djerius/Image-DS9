use strict;
use warnings;

use Test::More;

use Image::DS9;

BEGIN { plan( tests => 2 ) }

eval 'use PDL';
if ( $@ )
{
  plan( skip_all => 'No PDL; skipping' );
}

require 't/common.pl';

my $ds9 = start_up();

my $x = zeroes(20,20)->rvals;

eval {
  $ds9->array($x);
};

ok( ! $@, "PDL array" );
  
my $p = $x->get_dataref;
  
my @dims = $x->dims;
eval {
  $ds9->array($$p, { xdim => $dims[0], ydim => $dims[1], bitpix => -64 } );
};
ok ( ! $@, "raw array" );
