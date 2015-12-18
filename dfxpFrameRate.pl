#!/usr/bin/perl
use strict;	# Enforce some good programming rules

#
# DFXPFrameRate.pl
# version 0.1
# 
# created 2015-12-17
# modified 2015-12-17
# 
# created by Theron Trowbridge
#
# determine likely frame rate of a DFXP (SMPTE TT, ITT) subtitle file
# 
# file name is passed as first command line parameter
# likely frame rate is returned to STDOUT
# 

my $frameCount;
my $highestFrame;

# input file is first command line parameter
my $input_file = $ARGV[0];
if ( $input_file eq undef ) { die "frameRate.pl <filename>\n\nPlease specify an input file\n"; }

open( my $fh, '<', $input_file ) or die "Can't open file $input_file $!";

$highestFrame = 0;
while ( my $line = <$fh> ) {
	chomp $line;
	if ( $line =~ /begin=\"[0-9]{2}:[0-9]{2}:[0-9]{2}:([0-9]{2})\"/ ) {
		if ( $1 gt $highestFrame ) { $highestFrame = $1; }
	}
	if ( $line =~ /end=\"[0-9]{2}:[0-9]{2}:[0-9]{2}:([0-9]{2})\"/ ) {
		if ( $1 gt $highestFrame ) { $highestFrame = $1; }
	}
}

if ( $highestFrame gt 49 ) { print "60\n"; }
elsif ( $highestFrame gt 29 ) { print "50\n"; }
elsif ( $highestFrame gt 24 ) { print "30\n"; }
elsif ( $highestFrame eq 24 ) { print "25\n"; }
else { print "24\n"; }

# typical line:
#       <p style="style.center" region="region.after" begin="00:01:29:17" end="00:01:30:18" dur="00:00:01:01">[ SIREN WAILING ]</p>
