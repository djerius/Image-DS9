use strict;
use warnings;

use blib;
use Test::More;
our $use_PDL;

BEGIN { 
	plan( 'no_plan' );
	use_ok( 'Image::DS9' );
	eval 'use PDL';
	$use_PDL = ! $@;
      }

use File::stat;
use Data::Dumper;
use Cwd;


# TODO:
#  about?
#  analysis
#  full dss
#  full nameserver
#  full pan
#  full crosshair
#  regions
#  saveas
#  shm
#  source
#  tcl
#  update
#  vo
#  wcs
#  web





our $imgfile = "snooker.img.fits.gz";

my $ds9 = Image::DS9->new( { verbose => 0 });

eval { 
  start_up();
  easy_stuff();
  hard_stuff();
  pdl() if $use_PDL;
};

if ( $@ )
{
  print $@;
  print Dumper {$ds9->res}
    if $@ =~ /Image::DS9/;
}

sub start_up
{

  unless ( $ds9->nservers )
  {
    system( "ds9&" );
    $ds9->wait() or die( "unable to connect to DS9\n" );
  }

  $ds9->frame( delete => 'all' );
  $ds9->frame( 'new' );

  eval {
    $ds9->file( cwd() . "/snooker.fits", { extname => 'raytrace', 
					   bin => [ 'rt_x', 'rt_y' ] } );
  };
  $ds9->bin( factor => 0.025 );
  $ds9->lower();
  $ds9->raise();
  $ds9->zoom( 0 );
  ok( cwd() . "/snooker.fits[RAYTRACE]" eq $ds9->file(), "file name retrieval" );

  eval { 
    my $fitsimg = $ds9->fits( 'image', 'gz' );
    open ( FITS, ">$imgfile" ) or die( "unable to create $imgfile\n" );
    syswrite FITS, $$fitsimg;
    close FITS;
  };
  print STDERR $@ if $@;
  ok( !$@, "fits image gz get" );


}

sub hard_stuff
{

  $ds9->blink();
  ok( 1 == $ds9->blink('state'), "blink");

  $ds9->single();
  ok( 1 == $ds9->single('state'), "single" );
  ok( 0 == $ds9->blink('state'), "single; blink off");

  $ds9->crosshair( 0, 0, 'image' );
  ok( eq_array( scalar $ds9->crosshair( 'image' ), [0,0]), 'crosshair' );

  eval {
    $ds9->cursor( 1,1 );
  };
  print STDERR $@ if $@;
  ok ( ! $@, "cursor" );


  eval {
    my $sb = stat( $imgfile ) or die( "unable to stat $imgfile" );
    open( FILE, $imgfile ) or die( "unable to open $imgfile" );
    my $fitsimg;
    sysread FILE, $fitsimg, $sb->size;
    close FILE;
    $ds9->fits( $fitsimg, { new => 1 } );
  };
  print $@ if $@;
  ok( !$@, "fits image gz set" );


  $ds9->frame(3);
  ok( 3 == $ds9->frame(), "frame create" );

  ok( eq_array([ 1, 2, 3 ], scalar $ds9->frame('all')), 'frame all' );

  $ds9->frame( 'first' );
  ok( 1 == $ds9->frame(), "frame first" );

  $ds9->frame( 'last' );
  ok( 3 == $ds9->frame(), "frame last" );

  $ds9->frame( 'prev' );
  ok( 2 == $ds9->frame(), "frame prev" );

  $ds9->frame( 'next' );
  ok( 3 == $ds9->frame(), "frame next" );

  $ds9->frame( 'delete' );
  ok( 1 == $ds9->frame(), "frame delete" );

  $ds9->frame( 'new' );
  ok( 3 == $ds9->frame(), "frame new" );


  $ds9->grid(1);
  unlink 'snooker.grid';
  $ds9->grid( save => 'snooker.grid' );
  ok ( -f 'snooker.grid', 'grid save' );

  eval {
  $ds9->grid(0);
  $ds9->grid( load => 'snooker.grid' );
  };
  print $@ if $@;
  ok(!$@, 'grid load' );

  $ds9->file( cwd() . '/m31.fits.gz' );

  # FIXME
  if ( 0 ) # wait until ds9 has bug with static wcs fixed
  {
    my @coords = qw( 02:45:04.529 +41:16:07.93 );
    $ds9->crosshair( @coords, wcs => 'fk5');
    ok( eq_array( \@coords, 
		  scalar $ds9->crosshair(qw( wcs fk5 sexagesimal ))), 
	'crosshair' );
  }

  # FIXME
  if ( 0 ) # wait until ds9 has bug with static wcs fixed
  {
    my @coords = qw( 02:45:04.529 +41:16:07.93 );
    $ds9->pan( to => @coords, qw( wcs fk5) );
    ok( eq_array( \@coords, 
		  scalar $ds9->pan(qw( wcs fk5 sexagesimal ))), 
	'pan' );
  }

  $ds9->rotate( abs => 45 );
  ok( $ds9->rotate == '45', 'rotate abs' );

  $ds9->rotate( to => 45 );
  ok( $ds9->rotate == '45', 'rotate to' );

  $ds9->rotate( rel => 45 );
  ok( $ds9->rotate == '90', 'rotate rel' );

  $ds9->rotate( 45 );
  ok( $ds9->rotate == '135', 'rotate' );

  for my $mode ( qw ( row column grid ) )
  {
    $ds9->tile( $mode );
    ok( $ds9->tile('mode') eq $mode, "tile $mode" );
  }

  eval {
    $ds9->version();
  };
  ok ( ! $@, 'version' );

  $ds9->zoom( to => 'fit' );
  my $zval = $ds9->zoom;
  $ds9->zoom( to => 1);
  ok( 1 == $ds9->zoom, 'zoom to' );
  $ds9->zoom( abs => 2);
  ok( 2 == $ds9->zoom, 'zoom abs' );
  $ds9->zoom( rel => 2);
  ok( 4 == $ds9->zoom, 'zoom rel' );
  $ds9->zoom( 0.5);
  ok( 2 == $ds9->zoom, 'zoom' );
  $ds9->zoom( 0 );
  ok( $zval == $ds9->zoom, 'zoom 0' );


#  $ds9->exit;

}

sub easy_stuff
{
  my $view_stuff = 
    [
     ( map { $_ => 0, $_ => 1 } 
       qw( info panner magnifier buttons colorbar image physical wcs ),
     ),
     ( map { $_ => 1, $_ => 0 } 
       ( qw( horzgraph vertgraph ), map { 'wcs' . $_ } ('a'..'z') )
     ),
    ];

  my @stuff =
    (

     bin =>
     [
      about => [ 0.023, 0.023 ],
      buffersize => 256,
      cols => [ qw (rt_x rt_y ) ],
      factor => 0.050,
      depth => 1,
      filter => 'rt_time>0.5',
      function => 'average',
      smooth => 1,
      [qw(smooth function)] => 'boxcar',
      [qw(smooth radius)] => 3,
     ],

     cmap =>
     [
      [] => 'Heat',
      invert => 1,
      value => [0.2, 0.3],
     ],

     contour =>
     [
      [] => 1,
     ],

     dss =>
     [
      size => [10,10],
      server => 'stsci',
      survey => 'dss2blue',
     ],

     grid =>
     [
      [] => 1,
      [] => 0,
     ],

     iconify =>
     [
      [] => 1,
      [] => 0,
     ],

     minmax =>
     [
      mode => 'scan',
      mode => 'sample',
      mode => 'datamin',
      mode => 'irafmin',
      [] => 'scan',
      [] => 'sample',
      [] => 'datamin',
      [] => 'irafmin',
      interval => 22,
     ],

     mode =>
     [
      [] => 'crosshair',
      [] => 'colorbar',
      [] => 'pan',
      [] => 'zoom',
      [] => 'rotate',
      [] => 'examine',
      [] => 'pointer',
     ],

     nameserver =>
     [
      server => 'ned-sao',
      server => 'ned-eso',
      server => 'simbad-sao',
      server => 'simbad-eso',
      skyformat => 'degrees',
      skyformat => 'sexagesimal',
     ],

     orient =>
     [
      [] => 'x',
      [] => 'y',
      [] => 'xy',
      [] => 'none',
     ],

     page =>
     [
      [qw( setup orientation )] => 'landscape',
      [qw( setup orientation )] => 'portrait',
      [qw( setup pagescale )] => 'fixed',
      [qw( setup pagescale )] => 'scaled',
      [qw( setup pagesize )] => 'legal',
      [qw( setup pagesize )] => 'tabloid',
      [qw( setup pagesize )] => 'poster',
      [qw( setup pagesize )] => 'a4',
      [qw( setup pagesize )] => 'letter',
     ],

     pixeltable =>
     [
      [] => 1,
      [] => 0,
     ],

     print =>
     [
      destination => 'file',
      destination => 'printer',
      command => 'print_this',
      filename => 'print_this.ps',
      palette => 'gray',
      palette => 'cmyk',
      palette => 'rgb',
      level => 1,
      level => 2,
      interpolate => 0,
      interpolate => 1,
      resolution => 53,
      resolution => 72,
      resolution => 75,
      resolution => 150,
      resolution => 300,
      resolution => 600,
     ],

     scale =>
     [
      [] => 'linear',
      [] => 'log',
      [] => 'squared',
      [] => 'sqrt',
      [] => 'histequ',
      [] => 'linear',

      datasec => 1,
      datasec => 0,

      limits => [1, 100],
      mode => 'minmax',
      mode => 33,
      mode => 'zscale',
      mode => 'zmax',

      scope => 'global',
      scope => 'local',
     ],

     tile =>
     [
      [] => 1,
      mode => 'column',
      mode => 'row',
      mode => 'grid',
      [qw( grid mode )] => 'manual',
      [qw( grid mode )] => 'automatic',
      [qw( grid layout )] => [5,5],
      [qw( grid gap )] => 3,
      [] => 0,
     ],

     view => $view_stuff,

     stop => [],
    );

  while ( my ( $cmd, $subcmds ) = splice( @stuff, 0, 2 ) )
  {
    last if $cmd eq 'stop';
    while ( my ( $subcmd, $args ) = splice( @$subcmds, 0, 2 ) )
    {
      my @subcmd = ( 'ARRAY' eq ref $subcmd ? @$subcmd : $subcmd );
      $subcmd = join( ' ', @$subcmd) if 'ARRAY' eq ref $subcmd;

      $args = [ $args ] unless 'ARRAY' eq ref $args;

      my $ret;
      eval {
	$ds9->$cmd(@subcmd, @$args);
	$ret = $ds9->$cmd(@subcmd);
      };

      print($@) && fail( "$cmd $subcmd" ) if $@;

      if ( ! ref($ret) && 1 == @$args )
      {
	ok( $ret eq $args->[0], "$cmd $subcmd" );
      }
      elsif ( @$ret == @$args )
      {
	ok ( eq_array( $ret, $args ), "$cmd $subcmd" );
      }
      else
      {
	fail( "$cmd $subcmd" );
      }
    }
  }
}


sub pdl_stuff
{
  
  my $x = zeroes(20,20)->rvals;
  $ds9->array($x);
  
  my $p = $x->get_dataref;
  
  my @dims = $x->dims;
  $ds9->array($$p, { xdim => $dims[0], ydim => $dims[1], bitpix => -64 } );
}
