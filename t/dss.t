use strict;
use warnings;

use Test::More qw( no_plan );
use Image::DS9 qw( :all );

my $standalone = 0;
my $res;
my $server = 'test';
my $dsp = Image::DS9->new( { Server => $server } );

unless ( $dsp->nservers )
{
  system("ds9 -title $server &");
  $dsp->wait() or die( "unable to connect to DS9\n" );
}

$dsp->dss( DSS_server, DSS_STSCI );
ok( DSS_STSCI eq $dsp->dss( DSS_server ), 'dss server' );

$dsp->dss( DSS_survey, DSS_dss2blue );
ok( DSS_dss2blue eq $dsp->dss( DSS_survey ), 'dss survey' );

my @size = ( 30, 30 );
$dsp->dss( DSS_size, @size );
$res = $dsp->dss( DSS_size );
ok( eq_array( \@size, $res ), 'dss size' );

# run this only if this test is run as a single, standalone test.
# the DSS retrieve operation is done asynchronously, so this'll
# return before it's done and will mess up subsequent tests.
if ( $standalone )
{
  my @coords = qw( 04:54:19.029 +02:56:47.70 );
  $dsp->dss( DSS_coord, @coords );
  $res = $dsp->dss( DSS_coord );
  ok( eq_array( \@coords, $res ), 'dss coord' );
}
