use PDL;
use blib '.';
use Image::DS9 qw( :frame_ops );

my $ds9 = new Image::DS9;

my $k = zeroes(double, 50,50)->rvals;

$ds9->array( $k );

$ds9->frame( FOP_NEW );

$k = zeroes(double, 100, 100)->rvals;

$ds9->array( $k );

$ds9->blink(1);

	use Data::Dumper;
	my @colormaps = $ds9->colormap;
	print Dumper \@colormaps;

