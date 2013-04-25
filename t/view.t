use strict;
use warnings;

use Test::More;
use Image::DS9;
use Cwd;

BEGIN { plan( tests => 72 ) ;}

require 't/common.pl';


my $ds9 = start_up();

test_stuff( $ds9, (
		   view =>
		   [
		    ( map { $_ => 0, $_ => 1 } 
		      qw( info panner magnifier buttons 
			  image physical ),
		    ),
		    ( map { $_ => 'no', $_ => 'yes' } 
		      qw( colorbar ),
		    ),
		    ( map { $_ => 0, $_ => 1 } 
		      qw( wcs ),
		    ),
		    ( map { $_ => 1, $_ => 0 } 
		      ( map { 'wcs' . $_ } ('a'..'z') )
		    ),
		    ( map { $_ => 0, $_ => 1 } 
                      ( [ 'graph', 'horizontal' ],
                        [ 'graph', 'vertical' ] )
		    ),
		   ]
		  ) );
