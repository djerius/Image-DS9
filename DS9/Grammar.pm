package Image::DS9::Grammar;

use strict;
use warnings;

use Image::DS9::PConsts;

use constant REGIONFORMAT => ENUM( qw( ds9 ciao saotng saoimage pros xy ) );

# TODO:
#  about?
#  analysis
#  shm


our %Grammar =
  (

#------------------------------------------------------

   array =>
   [
    [ 
     [],
     { args => [ PDL ], 
       attrs => [ new    => BOOL ],
       query => QNONE,
       bufarg => 1
     },

     { args => [ SCALARREF ], 
       attrs => [ new    => BOOL,
		  bitpix => INT,
		  skip   => INT,
		  -o => [ ( -a => [ xdim => INT, ydim => INT ] ),
			  ( dim => INT ) ],
		],
       query => QNONE,
       bufarg => 1
     }

    ],

   ],

#------------------------------------------------------

   bin =>
   [ 
    [
     ['about'],
     { args => [ FLOAT, FLOAT ] }
    ],

    [
     ['buffersize'],
     { args => [ INT ] }
    ],

    [ 
     ['cols'],
     { args => [ STRING, STRING ] }
    ],

    [
     ['factor'],
     { args => [ FLOAT ] }
    ],

    [
     ['depth'],
     { args => [ INT ] }
    ],

    [
     ['filter'],
     { args => [ STRING ] }
    ],

    [
     ['function'],
     { args => [ ENUM( 'average', 'sum' ) ] }
    ],

    [
     [ REWRITE('tofit', 'to fit') ],
     { query => QNONE }
    ],

    [
     [ 'to fit' ],
     { query => QNONE }
    ],

    [ 
     [ 'smooth', 'function' ],
     { args => [ ENUM( 'boxcar', 'tophat', 'gaussian' ) ] }
    ],

    [ 
     [ 'smooth',  'radius' ],
     { args => [ FLOAT ] }
    ],

    [
     [ 'smooth' ],
     { args => [ BOOL ] }
    ],

   ],

#------------------------------------------------------

   blink =>
   [
    [
     [ EPHEMERAL('state') ],
     { rvals => [ BOOL ], query => QONLY },
    ],

    [
     [],
     { query => QNONE },
    ]
   ],


#------------------------------------------------------

   cmap =>
   [ 
    [
     ['file'],
     { args => [ STRING ] }
    ],

    [
     ['invert'],
     { args => [ BOOL ] }
    ],

    [
     ['value'],
     { args => [ FLOAT, FLOAT ] }
    ],

    [
     [],
     { args => [ STRING ] }
    ],
   ],

#------------------------------------------------------

   contour =>
   [

    [
     ['copy'],
     { query => QNONE }
    ],

    [
     ['paste'],
     { args => [ COORDSYS, SKYFRAME, COLOR, FLOAT ], query => QNONE },
     { args => [ COORDSYS, COLOR, FLOAT ], query => QNONE }
    ],

    [
     ['save'],
     { args => [ COORDSYS ], query => QNONE },
     { args => [ COORDSYS, SKYFRAME ], query => QNONE }
    ],

    [
     [],
     { args => [ BOOL ] }
    ],

   ],


#------------------------------------------------------

   crosshair =>
   [
    [
     [],
     { rvals => [STRING, STRING] },

     { args => [ COORDSYS ],
       query => QARGS|QYES,
       rvals => [STRING,STRING] },

     { args => [ COORDSYS, SKYFORMAT ],
       query => QARGS|QYES,
       rvals => [STRING, STRING] },

     { args => [ COORDSYS, SKYFRAME  ],
       query => QARGS|QYES,
       rvals => [STRING, STRING] },

     { args => [ COORDSYS, SKYFRAME, SKYFORMAT ],
       query => QARGS|QYES,
       rvals => [STRING, STRING] },

     { args => [ COORD_RA, COORD_DEC, COORDSYS ],
       query => QNONE,
     },

     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME ],
       query => QNONE,
     }
    ],

   ],

#------------------------------------------------------

   cursor =>
   [
    [
     [],
     { args => [ FLOAT, FLOAT ], query => QNONE }
    ]
   ],

#------------------------------------------------------

   dss =>
   [
    [
     ['name'],
     { args => [ STRING ] }
    ],

    [
     ['coordinate'],
     { args => [ COORD_RA, COORD_DEC ] }
    ],

    [
     ['server'],
     { args => [ ENUM( 'sao', 'stsci', 'eso', ) ] }
    ],

    [
     ['survey'],
     { args => [ ENUM( 'dss', 'dss2red', 'dss2blue' ) ] }
    ],

    [
     ['size'],
     { args => [ FLOAT, FLOAT ] }
    ],

   ],

#------------------------------------------------------

   exit =>
   [
    [ 
     [], 
     { query => QNONE } 
    ],
   ],


#------------------------------------------------------

   file =>
   [

    [ 
     [ENUM('fits', 'mosaic', 'mosaicimage')],
     { args => [ STRING ], 
       attrs => [ new => BOOL ],
       query => QNONE
     }
    ],

    [ 
     ['array'],
     { args => [ STRING ], 
       attrs => [ new    => BOOL,
		  bitpix => INT,
		  skip   => INT,
		  -o => [ [ -a => [ xdim => FLOAT, ydim => FLOAT ] ],
			  [ dim => FLOAT ] ],
		],
       query => QNONE,
     }
    ],

    [ 
     ['url'],
     { args => [ STRING ], 
       attrs => [ new => BOOL ],
       query => QNONE,
     }
    ],

    [ 
     ['save'],
     { args => [ STRING ], 
       query => QNONE,
     }
    ],

    [ 
     ['save', 'gz'],
     { args => [ STRING ], 
       query => QNONE,
     }
    ],

    [ 
     ['save', 'resample'],
     { args => [ STRING ], 
       query => QNONE,
     }
    ],

    [ 
     ['save', 'resample', 'gz'],
     { args => [ STRING ], 
       query => QNONE,
     }
    ],

    [ 
     [],
     { args => [ STRING ], 
       attrs => [ new => BOOL,
		  extname => STRING,
		  filter => STRING,
		  bin => ARRAY(1,2),
		],
     }
    ],

   ],

#------------------------------------------------------

   fits =>
   [

    [
     ['mosaic'],
     { args => [ SCALARREF ],
       attrs => [ new => BOOL,
		  extname => STRING,
		  filter => STRING,
		  bin => ARRAY(1,2),
		],
       query => QNONE,
       bufarg => 1,
       cvt => 0,
       retref => 1,
       chomp => 0,
     }
    ],

    [
     ['mosaicimage'],
     { args => [ SCALARREF ],
       attrs => [ new => BOOL,
		  extname => STRING,
		  filter => STRING,
		  bin => ARRAY(1,2),
		],
       query => QNONE,
       bufarg => 1,
       cvt => 0,
       retref => 1,
       chomp => 0,
     }
    ],

    [
     ['type'],
     { query => QONLY }
    ],

    [
     ['image', 'gz'],
     { query => QONLY,
       cvt => 0,
       rvals => [STRING],
       retref => 1,
       chomp => 0,
     }
    ],

    [
     ['image'],
     { query => QONLY,
       cvt => 0,
       rvals => [STRING],
       retref => 1,
       chomp => 0,
     }
    ],

    [
     ['resample', 'gz'],
     { query => QONLY,
       cvt => 0,
       rvals => [STRING],
       retref => 1,
       chomp => 0,
     }
    ],

    [
     ['resample'],
     { query => QONLY,
       cvt => 0,
       rvals => [STRING],
       retref => 1,
       chomp => 0,
 }
    ],

    [
     [],
     { args => [ SCALARREF ],
       attrs => [ new => BOOL,
		  extname => STRING,
		  filter => STRING,
		  bin => ARRAY(1,2),
		],
       query => QYES,
       bufarg => 1,
       cvt => 0,
       retref => 1,
       chomp => 0,
     }
    ],

   ],

#------------------------------------------------------

   frame =>
   [

    [
     ['all'],
     { query => QONLY, rvals => [ ARRAY ], retref => 1 }
    ],

    [
     ['first'],
     { query => QNONE }
    ],

    [
     ['next'],
     { query => QNONE }
    ],

    [
     ['prev'],
     { query => QNONE }
    ],

    [
     ['last'],
     { query => QNONE }
    ],

    [
     ['new'],
     { query => QNONE }
    ],

    [
     ['delete'],
     { query => QNONE },
     { args => [ INT ], query => QNONE },
     { args => [ ENUM( 'all' ) ], query => QNONE }
    ],

    [
     ['reset'],
     { query => QNONE }
    ],

    [
     ['refresh'],
     { query => QNONE }
    ],

    [
     ['center'],
     { query => QNONE }
    ],

    [
     ['hide'],
     { query => QNONE }
    ],

    [
     ['show'],
     { args => [ INT ], query => QNONE },
    ],

    [
     [],
     { args => [ INT ] }
    ],

   ],


#------------------------------------------------------

   grid =>
   [

    [
     ['load'],
     { args => [ STRING ], query => QNONE },
    ],

    [
     ['save'],
     { args => [ STRING ], query => QNONE },
    ],

    [
     [],
     { args => [ BOOL ] }
    ],

   ],

#------------------------------------------------------

   iconify =>
   [
    [
     [],
     { args => [ BOOL ] }
    ],
   ],

#------------------------------------------------------

   lower =>
   [
    [
     [],
     { query => QNONE }
    ],
   ],


#------------------------------------------------------

   minmax =>
   [

    [
     ['mode'],
     { args => [ ENUM( 'scan', 'sample', 'datamin', 'irafmin' ) ] }
    ],

    [
     ['interval'],
     { args => [ INT ] }
    ],

    [
     [],
     { args => [ ENUM( 'scan', 'sample', 'datamin', 'irafmin' ) ] }
    ],

   ],

#------------------------------------------------------

   mode =>
   [
    [
     [],
     { args => [ ENUM( 'pointer', 'crosshair', 'colorbar', 'pan',
		       'zoom', 'rotate', 'examine' ) ],
     }
    ],
   ],

#------------------------------------------------------

   nameserver =>
   [

    [
     ['name'],
     { args => [STRING], query => QNONE }
    ],

    [
     ['server'],
     { args => [ ENUM( 'ned-sao', 'ned-eso', 'simbad-sao', 'simbad-eso' ) ] },
    ],

    [
     ['skyformat'],
     { args => [ SKYFORMAT ] }
    ],

    [
     [],
     { args => [STRING], query => QNONE }
    ],

   ],

#------------------------------------------------------

   orient =>
   [
    [
     [],
     { args => [ ENUM( 'none', 'x', 'y', 'xy' ) ] },
    ],
   ],

#------------------------------------------------------

   page =>
   [

    [
     ['setup', 'orientation'],
     { args => [ ENUM( 'portrait', 'landscape' ) ], }
    ],

    [
     ['setup', 'pagescale'],
     { args => [ ENUM( 'scaled', 'fixed' ) ], }
    ],

    [
     ['setup', 'pagesize'],
     { args => [ ENUM( 'letter', 'legal', 'tabloid', 'poster', 'a4' ) ], }
    ],

   ],


#------------------------------------------------------

   pan =>
   [

    [
     [ 'to' ],
     { args => [ COORD_RA, COORD_DEC ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFORMAT ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME  ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME, SKYFORMAT ], 
       query => QNONE },
    ],

    [
     [ REWRITE( 'abs', 'to' ) ],
     { args => [ COORD_RA, COORD_DEC ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFORMAT ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME  ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME, SKYFORMAT ], 
       query => QNONE },
    ],

    [
     [ EPHEMERAL( 'rel' ) ],
     { args => [ COORD_RA, COORD_DEC ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFORMAT ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME  ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME, SKYFORMAT ], 
       query => QNONE },
    ],

    [
     [],
     { args => [ COORD_RA, COORD_DEC ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFORMAT ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME  ], query => QNONE },
     { args => [ COORD_RA, COORD_DEC, COORDSYS, SKYFRAME, SKYFORMAT ], 
       query => QNONE },

     { rvals => [STRING, STRING],
       cvt => 0
     },

     { args => [ COORDSYS, SKYFRAME ],
       query => QONLY,
       rvals => [STRING, STRING],
       cvt => 0
     },

     { args => [ COORDSYS, SKYFORMAT ], 
       query => QONLY,
       rvals => [STRING, STRING],
       cvt => 0
     },

     { args => [ COORDSYS, SKYFRAME, SKYFORMAT ],
       query => QONLY,
       rvals => [STRING, STRING],
       cvt => 0
     },
    ],

   ],

#------------------------------------------------------

   pixeltable =>
   [
    [
     [],
     { args => [ BOOL ] },
    ],
   ],

#------------------------------------------------------

   print =>
   [

    [
     ['destination'],
     { args => [ ENUM( 'printer', 'file' ) ] },
    ],

    [
     ['command'],
     { args => [ STRING ] },
    ],

    [
     ['filename'],
     { args => [ STRING ] },
    ],

    [
     ['palette'],
     { args => [ ENUM( 'rgb', 'cmyk', 'gray' ) ] },
    ],

    [
     ['level'],
     { args => [ ENUM( '1', '2' ) ] },
    ],

    [
     ['interpolate'],
     { args => [ BOOL ] },
    ],

    [
     ['resolution'],
     { args => [ ENUM( qw( 53 72 75 150 300 600  )) ] },
    ],

    [
     [],
     { query => QNONE }
    ],

   ],


#------------------------------------------------------

   quit =>
   [
    [
     [],
     { query => QNONE },
    ]
   ],


#------------------------------------------------------

   raise =>
   [
    [
     [],
     { query => QNONE },
    ]
   ],


#------------------------------------------------------

   regions =>
   [

    [
     [ENUM( qw( movefront moveback selectall selectnone deleteall )) ],
     { query => QNONE },
    ],


    [
     [ENUM( qw( load save ) )],
     { args => [ STRING ], query => QNONE },
    ],

    [
     ['format'],
     { args => [ REGIONFORMAT ] },
    ],

    [
     ['system'],
     { args => [ COORDSYS ] },
    ],

    [
     ['sky'],
     { args => [ SKYFRAME ] },
    ],

    [
     ['skyformat'],
     { args => [ SKYFORMAT ] },
    ],

    [
     ['strip'],
     { args => [ BOOL ] },
    ],

    [ 
     [ENUM(qw(source background include exclude selected)) ],
     { query => QONLY }
    ],

    [
     ['shape'],
     { args => [STRING] }
    ],

    [ 
     ['width'],
     { args => [INT] }
    ],

    [ 
     ['color'],
     { args => [ENUM(qw( black white red green blue cyan magenta yellow))] }
    ],


    [
     [],
     { args => [STRING_NL], 
       query => QNONE, 
       bufarg => 1,
     },
     { query => QYES|QONLY|QATTR, 
       rvals => [ STRING ],
       attrs => [
		 -format => REGIONFORMAT,
		 -system => COORDSYS,
		 -sky    => SKYFRAME,
		 -skyformat => SKYFORMAT,
		 -strip  => BOOL,
		 -prop   => ENUM(qw( select edit move rotate delete fixed 
				     include source )),
		] 
     }
    ],

   ],

#------------------------------------------------------

   rotate =>
   [

    [
     [ 'to' ],
     { args => [FLOAT], query => QNONE },
    ],

    [
     [ REWRITE( 'abs', 'to' ) ],
     { args => [FLOAT], query => QNONE },
    ],

    [
     [ EPHEMERAL( 'rel' ) ],
     { args => [FLOAT], query => QNONE },
    ],


    [
     [],
     { args => [FLOAT] },
    ],

   ],

#------------------------------------------------------

   saveas =>
   [
    [
     [ENUM( qw( jpeg tiff png ppm ) )],
     { args => [ STRING ], query => QNONE },
    ]
   ],

#------------------------------------------------------

   scale =>
   [

    [
     ['datasec'],
     { args => [ BOOL ] },
    ],

    [
     ['limits'],
     { args => [ FLOAT, FLOAT ] },
    ],

    [
     ['mode'],
     { args => [ ENUM( qw( minmax zscale zmax ) ) ] },
     { args => [ FLOAT ] },
    ],

    [
     ['scope'],
     { args => [ ENUM( qw( local global ) ) ] },
    ],

    [
     [],
     { args => [ ENUM( qw( linear log squared sqrt histequ ) ) ] }
    ],

   ],

#------------------------------------------------------

   single =>
   [
    [
     [ EPHEMERAL('state') ],
     { rvals => [ BOOL ], query => QONLY },
    ],

    [
     [],
     { query => QNONE },
    ]
   ],

#------------------------------------------------------

   source =>
   [
    [
     [],
     { args => [STRING], query => QNONE },
    ],
   ],

#------------------------------------------------------

   tcl =>
   [
    [
     [],
     { args => [STRING], query => QNONE },
    ],
   ],

#------------------------------------------------------

   tile =>
   [
    [
     [ 'mode' ],
     { args => [ ENUM('grid', 'column', 'row' ) ] }
    ],

    [
     ['grid', 'mode'],
     {args => [ ENUM('automatic','manual') ] },
    ],

    [
     ['grid', 'layout'],
     { args => [ INT, INT ] },
    ],

    [
     [ 'grid', 'gap' ],
     { args => [ INT ] },
    ],

    [
     [ENUM('grid', 'row', 'column')],
     { query => QNONE },
    ],

    [
     [ EPHEMERAL('state') ],
     { rvals => [ BOOL ], query => QONLY },
    ],

    [
     [],
     { args => [ BOOL ] }
    ],
   ],

#------------------------------------------------------

   update =>
   [
    [],
    { attrs => [ now => BOOL ], query => QNONE },
    { args => [ INT, FLOAT, FLOAT, FLOAT, FLOAT ], 
      attrs => [ now => BOOL ], 
      query => QNONE }
   ],

#------------------------------------------------------

   version =>
   [
    [
     [],
     { rvals => [STRING],
       query => QONLY },
    ],
   ],

#------------------------------------------------------

   view =>
   [
    [
     [ENUM( qw( info panner magnifier
		buttons colorbar horzgraph vertgraph ) )],
     { args => [ BOOL ] },
    ],

    [
     [COORDSYS],
     { args => [ BOOL ] },
    ]
   ],

#------------------------------------------------------

   vo =>
   [
    [
     [],
     { args => [ STRING ] }
    ],
   ],

#------------------------------------------------------

   wcs =>
   [

    [
     ['system'],
     { args => [ WCSS ] }
    ],

    [
     ['sky'],
     { args => [ SKYFRAME ] }
    ],

    [
     ['skyformat'],
     { args => [ SKYFORMAT ] }
    ],

    [
     ['align'],
     { args => [ BOOL ] }
    ],

    [
     ['reset'],
     { query => QNONE },
    ],


    [
     ['replace', 'file' ],
     { args => [ STRING ], query => QNONE },
    ],

    [
     ['append', 'file' ],
     { args => [ STRING ], query => QNONE },
    ],

    [
     [ENUM( 'replace', 'append' )],
     { args => [ WCS_SCALARREF ], query => QNONE, bufarg => 1 },
     { args => [ WCS_HASH ], query => QNONE, bufarg => 1 },
     { args => [ WCS_ARRAY ], query => QNONE, bufarg => 1 },
    ],

    [
     [],
     { args => [ WCSS ] },
    ],

   ],

#------------------------------------------------------

   web =>
   [
    [ 
     [], 
     { args => [STRING] }
    ]
   ],


#------------------------------------------------------

   zoom =>
   [
    [
     [ 'to' ],
     { args => [FLOAT], query => QNONE },
     { args => ['fit'], query => QNONE },
    ],

    [
     [ REWRITE( 'abs' => 'to') ],
     { args => [FLOAT], query => QNONE },
    ],

    [
     [ EPHEMERAL('rel') ],
     { args => [FLOAT], query => QNONE },
    ],

    [
     [ REWRITE( '0' => 'to fit' ) ],
     { query => QNONE },
    ],

    [
     [ REWRITE( tofit => 'to fit' ) ],
     { query => QNONE },
    ],

    [ 
     [],
     { args => [FLOAT] }
    ],

   ]
  );


1;

