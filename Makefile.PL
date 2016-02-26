#! perl

use strict;
use warnings;
use inc::Module::Install;

name	'Image-DS9';
license 'gpl3';
auto_license( holder => 'Smithsonian Astrophysical Observatory' );
all_from 'lib/Image/DS9.pm';

requires 'IPC::XPA' => '0.08';
test_requires 'Test::More' => '0.31';
requires_external_bin 'ds9';

cpanfile;

WriteAll;
