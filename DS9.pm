package Image::DS9;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $use_PDL);


BEGIN {
  eval "use PDL::Types; use PDL::Core"; 
  $use_PDL = $@ ? 0 : 1;
}


require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw( );

my @frame_ops = qw( FOP_NEW FOP_DELETE FOP_RESET 
		    FOP_REFRESH FOP_CENTER FOP_HIDE FOP_SHOW );

my @tile_ops  = qw( T_GRID T_COLUMN T_ROW );

my @extra_ops = qw( ON OFF );

@EXPORT_OK = ( @frame_ops, @tile_ops, @extra_ops );

%EXPORT_TAGS = ( 
		frame_ops => \@frame_ops,
		tile_ops => \@tile_ops,
		all => [ @frame_ops, @tile_ops, @extra_ops ],
	       );
$VERSION = '0.03';

use Carp;
use Data::Dumper;
use IPC::XPA;
use constant SERVER => 'ds9';
use constant CLASS => 'Image::DS9';


use constant ON		 => 1;
use constant OFF	 => 0;


# Preloaded methods go here.

sub _flatten_hash
{
  my ( $hash ) = @_;

  return '' unless keys %$hash;

  join( ',', map { "$_=" . $hash->{$_} } keys %$hash );
}

# create new XPA object
{

  my %def_obj_attrs = ( Server => SERVER );
  my %def_xpa_attrs = ( max_servers => 1 );

  sub new
  {
    my ( $class, $u_attrs ) = @_;
    $class = ref($class) || $class;
    
    # load up attributes, first from defaults, then
    # from user.  ignore bogus elements in user attributes hash
    my %obj_attrs = %def_obj_attrs;
    my %xpa_attrs = %def_xpa_attrs;

    if ( $u_attrs )
    {
      $obj_attrs{$_} = $u_attrs->{$_} 
        foreach grep { exists $obj_attrs{$_} } keys %$u_attrs;

      $xpa_attrs{$_} = $u_attrs->{$_} 
        foreach grep { exists $xpa_attrs{$_} } keys %$u_attrs;
    }

    my $self = bless { 
		      xpa => IPC::XPA->Open, 
		      %obj_attrs,
		      xpa_attrs => \%xpa_attrs,
		      res => undef
		     }, $class;
    
    croak( CLASS, "->new -- error creating XPA object" )
      unless defined $self->{xpa};

    $self;
  }
}

sub nservers
{
  my $self = shift;

  $self->{xpa}->Access( $self->{Server}, 'gs' );
}

sub res
{
  my $self = shift;

  $self->{res};
}

{
  # mapping between PDL
  my %map;

  if ( $use_PDL )
  {
    # if PDL isn't there, this'll cause compile time errors
    eval q{
    %map = (
	    $PDL::Types::PDL_B => 8,
	    $PDL::Types::PDL_S => 16,
	    $PDL::Types::PDL_S => 16,
	    $PDL::Types::PDL_L => 32,
	    $PDL::Types::PDL_F => -32,
	    $PDL::Types::PDL_D => -64
	   );}
  }

  my %def_attrs = ( xdim => undef,
		    ydim => undef,
		    bitpix => undef );
  
  sub array
  {
    my ( $self, $image, $attrs ) = @_;
    
    my %attrs = ( $attrs ? %$attrs : () );

    my $data = $image;

    if ( $use_PDL && 'PDL' eq ref( $image ) )
    {
      $attrs{bitpix} = $map{$image->get_datatype};
      ($attrs{xdim}, $attrs{ydim}) = $image->dims;
      $data = ${$image->get_dataref};
    }
    
    if ( exists $attrs{dim} )
    {
      delete $attrs{xdim};
      delete $attrs{ydim};
    }

    my @notset = grep { ! defined $attrs{$_} } keys %attrs;
    croak( CLASS, '->array -- the following attributes were not defined: ',
	   join( ',', map { "'$_'" } @notset) )
      if @notset;

    $self->_Set( 'array ['._flatten_hash(\%attrs).']', $data );
  }
}

sub blink
{
  my ( $self, $state ) = @_;

  unless ( defined $state )
  {
    return $self->_Get( 'blink' );
  }

  else
  {
    $self->_Set( "blink $state" );
  }

}

sub tile
{
  my ( $self, $state ) = @_;

  unless ( defined $state )
  {
    return $self->_Get( 'tile' );
  }

  else
  {
    $self->_Set( "tile $state" );
  }

}

use constant T_GRID	 => 'grid';
use constant T_COLUMN	 => 'column';
use constant T_ROW	 => 'row';

sub tile_mode
{
  my ( $self, $state ) = @_;

  unless ( defined $state )
  {
    return $self->_Get( 'tile mode' );
  }

  else
  {
    $self->_Set( "tile mode $state" );
  }

}

sub colormap
{
  my ( $self, $colormap ) = @_;

  unless ( defined $colormap )
  {
    return $self->_Get( 'colormap' );
  }

  else
  {
    $self->_Set( "colormap $colormap" );
  }
}

use constant FOP_NEW     => 'new';
use constant FOP_DELETE  => 'delete';
use constant FOP_RESET   => 'reset';
use constant FOP_REFRESH => 'refresh';
use constant FOP_CENTER  => 'center';
use constant FOP_HIDE    => 'hide';
use constant FOP_SHOW    => 'show';

sub frame
{
  my ( $self, $cmd ) = @_;

  unless( defined $cmd )
  {
    return $self->_Get( 'frame' );
  }

  else
  {
    $self->_Set( "frame $cmd" );
  }


}

sub _Set
{
  my ( $self, $cmd, $buf ) = @_;

  my @res = $self->{xpa}->Set( $self->{Server}, $cmd, $buf, $self->{xpa_attrs} );
  if ( grep { defined $_->{message} } @res )
  {
    $self->{res} = \@res;
    croak( CLASS, " -- error sending data to server" );
  }
}

sub _Get
{
  my ( $self, $cmd ) = @_;
  my @res = $self->{xpa}->Get( $self->{Server}, $cmd, $self->{xpa_attrs} );
  if ( grep { defined $_->{message} } @res )
  {
    $self->{res} = \@res;
    croak( CLASS, " -- error sending data to server" );
  }
  
  if ( 1 == $self->{xpa_attrs}{max_servers} )
  {
    return $res[0]->{buf};
  }
  else
  {
    return map { { name => $_->{name}, buf => $_->{buf} } } @res;
  }
}



# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Image::DS9 - interface to the DS9 image display and analysis program

=head1 SYNOPSIS

  use Image::DS9;
  use Image::DS9 qw( :frame_ops );

  $dsp = new Image::DS9;
  $dsp = new Image::DS9( \%attrs );

  $nservers = $dsp->nservers;

  $dsp->array( $image );
  $dsp->array( $image, \%attrs );

  $dsp->blink( $state );

  $dsp->colormap( $colormap );
  @colormaps = $dsp->colormap;

  $dsp->frame( $frame_op );
  @frames = $dsp->frame;

  $last_results = $dsp->res;

=head1 DESCRIPTION

This class provides access to the B<DS9> image display and analysis
program through its B<XPA> access points.

B<DS9> is a rather flexible and feature-rich image display program.
Rather than extol its virtues, please consult the website in
L</REQUIREMENTS>.

This class is rather bare at present, providing a low level
interface to the XPA access points.  Eventually these will be
hidden by an elegant framework that will make life wonderful.

To use this class, first construct a B<Image::DS9> object, and
then apply it's methods.  It is possible to both address more
than one B<DS9> with a single object, as well as having
multiple B<Image::DS9> objects communicate with their own
B<DS9> invocations.  Eventually there will be documentation
spelling out how to do this.


=head1 METHODS

=head2 Constants

Predefined constants may be imported when the B<Image::DS9> package
is loaded, by specifying one or more of the following tags:
C<frame_ops>, C<tile_ops>, C<all>.  For example:

	use Image::DS9 qw( :frame_ops :tile_ops );

The C<frame_ops> group imports
C<FOP_NEW>,
C<FOP_DELETE>,
C<FOP_RESET>,
C<FOP_REFRESH>, 
C<FOP_CENTER>, 
C<FOP_HIDE>,
C<FOP_SHOW>.

The C<tile_ops> group imports
C<T_GRID>,
C<T_COLUMN>,
C<T_ROW>.

The C<all> group imports all of the above groups, as well as
C<ON>,
C<OFF>.


=head2 Return values

Because a single B<Image::DS9> object may communicate with multiple
instances of B<DS9>, most return values are lists, rather than scalars.
These are lists of hashes, with keys C<name> and C<buf>.  For example,

	use Data::Dumper;
	@colormaps = $dsp->colormap;
	print Dumper \@colormaps;

yields

	$VAR1 = [
	          {
	            'name' => 'DS9:ds9 838e2ab4:32832',
	            'buf' => 'Grey
	'
	          }
	        ];

Note the end of line character in the colormap name.

B<However>, if the object was created with B<max_servers> set to 1,
it returns the contents of C<buf> directly, i.e.

	$colormap = $dsp->colormap;

=head2 Error Returns

In case of error, an exception is thrown, and the results
from the XPA call which failed are made available via the B<res>
method.

=head2 Methods

=over 8

=item new

  $dsp = new Image::DS9;
  $dsp = new Image::DS9( \%attrs );

Construct a new object.  It returns a handle to the object.  It throws
an exception (catch via B<eval>) upon error.

The optional hash B<attrs> may contain one of the following keys:

=over 8

=item Server

An alternate server to which to communicate.  It defaults to C<ds9>.

=item max_servers

The maximum number of servers to which to communicate.  It defaults to
C<1>

=back

For example,

	$dsp = new Image::DS9( { max_servers => 3 } );



=item nservers

  $nservers = $dsp->nservers;

This returns the number of servers which the object is communicating
with.

=item array

  $dsp->array( $image );
  $dsp->array( $image, \%attrs );

This is a simple interface to the B<array> access point, which displays
images.  If B<$image> is a PDL object, all required information is
extracted from it, and it is passed to B<DS9>.  Otherwise, it should
be binary data suitable for B<DS9>, and the B<attrs> hash should be
used to pass dimensional and size data to B<DS9>.  B<attrs> may
contain the following elements:

=over 8

=item xdim

The X coordinate array extent.

=item ydim

The Y coordinate array extent.

=item bitpix

The number of bits per pixel.  Negative values indicate a floating point
number.

=back

=item blink

  $dsp->blink( $state );

Turn frame blinking on or off.  B<$state> may be the constants 
C<ON>, C<OFF>, C<'yes'>, C<'no'>, C<0>, C<1>.  If called without a value,
it will return the current status of frame blinking.

=item tile

  $dsp->tile( $state );

Control tiling of frames.  Set C<$state> to either C<ON> or C<OFF> (or
C<'yes'>, C<'no'>, or C<1>, C<0>) to turn tiling on or off.  If called
without a value, it will return the current status of frame blinking.

=item tile_mode

  $dsp->tile_mode( $mode );

The tiling mode may be specified by setting C<$mode> to C<T_GRID>,
C<T_COLUMN>, or C<T_ROW>.  These constants are available if the
C<tile_op> tags are imported.  Otherwise, use C<'mode grid'>, c<'mode
column'>, or C<'mode row'>.  If called without a value, it will return
the current tiling mode.


=item colormap

  $dsp->colormap( $colormap );
  @colormaps = $dsp->colormap;

If an argument is specified, it should be the name of a colormap (case
is not important).  If no arguments are specified, the current colormaps
for all of the B<DS9> instances is returned, as a list containing
references to hashes with the keys C<name> and C<buf>.  The latter
will contain the colormap name.


=item frame

  $dsp->frame( $frame_op );
  @frames = $dsp->frame;

Command B<DS9> to do frame operations.  Frame operations are nominally
strings.  As B<DS9> will interpret any string which isn't a frame operation
as the name of frame to switch to (or create, if necessary), B<Image::DS9>
provides constants for the standard operations to prevent typos.  See
the L<Constants> section.
Otherwise, use the strings C<'new'>, C<'delete'>, C<'reset'>
C<'refresh'>, C<'center'>, C<'hide'>, C<'show'>.

To load a particular frame, specify the frame name as the operator.

For example,

	$dsp->frame( FOP_NEW );		# use the constant
	$dsp->frame( 'new' );		# use the string literal
	$dsp->frame( '3' );		# load frame 3
	$dsp->frame( FOP_DELETE );	# delete the current frame

If B<frame()> is called with no arguments, it returns a list of the
current frames for all instances of B<DS9>.

=item res

  $res = $dsp->res;

In case of error, the returned results from the failing B<XPA> call
are available via this method.  It returns a reference to an
array of hashes, one per instance of B<DS9> addressed by the object.
See the B<IPC::XPA> documentation for more information on what
the hashes contain.


=back


=head1 REQUIREMENTS

B<Image::DS9> requires B<IPC::XPA> to be installed.  At present, both
B<DS9> and B<xpans> (part of the B<XPA> distribution) must be running
prior to any attempts to access B<DS9>.  B<DS9> will automatically
start B<xpans> if it is in the user's path.

B<DS9> is available at C<http://hea-www.harvard.edu/RD/ds9/>.

B<XPA> is available at C<http://hea-www.harvard.edu/RD/xpa/>.

=head1 AUTHOR

Diab Jerius ( djerius@cfa.harvard.edu )

=head1 SEE ALSO

perl(1), IPC::XPA.

=cut
