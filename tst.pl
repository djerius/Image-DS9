#!/proj/axaf/bin/perl -w

use Data::Dumper;
use PDL;
use Image::DS9 qw( :all );

my $ds9 = new Image::DS9( { max_servers => 1, res_wanthash => 0 } );

my $k = zeroes(double, 50,50)->rvals;

$ds9->array( $k );

$ds9->frame( FOP_NEW );

$k = zeroes(double, 100, 100)->rvals;

$ds9->array( $k );

$ds9->display( D_blink );

print $ds9->display, "\n";

$ds9->display eq D_blink or die( "display state not blink?" );

$ds9->display( D_tile );

$ds9->display eq D_tile or die( "display state not tile?" );

$ds9->tile_mode( T_ROW );
$ds9->tile_mode( T_COLUMN );

print "colormap = ", $ds9->colormap, "\n";

