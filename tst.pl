#!/proj/axaf/bin/perl -w

use Data::Dumper;
use PDL;
use Image::DS9 qw( :all );

my $ds9 = new Image::DS9;

my $k = zeroes(double, 50,50)->rvals;

$ds9->array( $k );

$ds9->frame( FOP_NEW );

$k = zeroes(double, 100, 100)->rvals;

$ds9->array( $k );

$ds9->blink( ON );

$ds9->tile( ON );

$ds9->tile_mode( T_ROW );
$ds9->tile_mode( T_COLUMN );
print "colormap = ", $ds9->colormap, "\n";

