use strict;
use warnings;

use Test::More;
use Image::DS9;
use Cwd;

BEGIN { plan( tests => 3 ) ;}

require 't/common.pl';


my $ds9 = start_up();

test_stuff( $ds9, (
		   dss =>
		   [
		    size => [10,10],
		    server => 'stsci',
		    survey => 'dss2blue',
		   ],
		  ) );

