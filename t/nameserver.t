use strict;
use warnings;

use Test::More tests => 6;
use Image::DS9;
use Cwd;

require 't/common.pl';


my $ds9 = start_up();

test_stuff( $ds9, (
		   nameserver =>
		   [
		    server => 'ned-sao',
		    server => 'ned-eso',
		    server => 'simbad-sao',
		    server => 'simbad-eso',
		    skyformat => 'degrees',
		    skyformat => 'sexagesimal',
		   ],
		  ) );

$ds9->nameserver( 'close' );
