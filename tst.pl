#!/proj/axaf/bin/perl -w

use strict;
use Data::Dumper;
use PDL;
use Image::DS9 qw( :all );
my $ds9 = new Image::DS9( { max_servers => 1, verbose => 1 } );

$ds9->frame( delete => FR_all );
$ds9->display( D_single );

$ds9->frame( FR_new );
my $k = zeroes(double, 50,50)->rvals;
$ds9->array( $k );

$ds9->mode( MB_pointer );

$ds9->frame( FR_new );
$k = zeroes(double, 100, 100)->rvals;
$ds9->array( $k );

for my $state ( @Image::DS9::display_ops_dbg )
{
  $ds9->display( $state );
  $ds9->display eq $state or die( "display state not $state?" );
}

$ds9->display( D_tile );

for my $state ( @Image::DS9::tile_ops_dbg )
{
  $ds9->tile_mode( $state );
  $ds9->tile_mode eq $state or die( "tile mode not $state\n" );
}

$ds9->display( D_single );
$ds9->rotate( 45 );
$ds9->rotate == 45 or die( "not rotated by 45?\n" );

$ds9->zoom( abs => 2 );
$ds9->zoom == 2 or die( "not zoomed to 2?\n" );

$ds9->zoom( rel => 2 );
$ds9->zoom == 4 or die( "not zoomed to 4?\n" );

$ds9->zoom( 0 );

foreach my $state ( qw( yes no ) )
{
  $ds9->iconify( $state );
  $ds9->iconify eq $state or die( "iconify not $state\n" );
}

foreach my $state ( @Image::DS9::scale_scopes )
{
  $ds9->scale( scope => $state );
  $ds9->scale( S_scope)  eq $state or die( "scale scope not $state\n" );
}

foreach my $state ( @Image::DS9::scale_algs )
{
  $ds9->scale( $state );
  $ds9->scale  eq $state or die( "scale not $state\n" );
}

foreach my $state ( @Image::DS9::scale_modes )
{
  $ds9->scale( mode => $state );
  $ds9->scale( S_mode )  eq $state or die( "scale mode not $state\n" );
}

foreach my $state ( @Image::DS9::orient_ops_dbg )
{
  $ds9->orient( $state );
  $ds9->orient() eq $state or die( "orientation not $state\n" );
}

$ds9->mode( MB_crosshair );
for my $state ( @Image::DS9::mode_ops_dbg )
{
  $ds9->mode( $state );
  $ds9->mode eq $state or die( "mode not $state\n" );
}
$ds9->mode( MB_pointer );

print "colormap = ", scalar $ds9->colormap, "\n";

