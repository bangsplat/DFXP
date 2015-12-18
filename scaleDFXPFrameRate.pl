#!/usr/bin/perl
use strict;	# Enforce some good programming rules

#
# scaleDFXPFrameRate.pl
# version 0.1
# 
# created 2015-12-17
# modified 2015-12-17
# 
# created by Theron Trowbridge
#
# adjust timecodes in a DFXP file
# 
# file name is passed as first command line parameter
# desired output frame rate is the second command line parameter
# 	if omitted, default is 24 fps
# input file's frame rate is the third command line parameter
# 	if omitted, dfxpFrameRate.pl is used to guess at likely frame rate
# 	if that doesn't work, default is 60 fps
# 

my $input_file = $ARGV[0];
my $output_frame_rate = $ARGV[1];
my $input_frame_rate = $ARGV[2];
my $adjusted_frame;

if ( $input_file eq undef ) { die "frameRate.pl <filename>\n\nPlease specify an input file\n"; }
open( my $fh, '<', $input_file ) or die "Can't open file $input_file $!";

if ( $output_frame_rate eq undef ) { $output_frame_rate = 24; }

# if input frame rate not specified, try to guess what it is
if ( $input_frame_rate eq undef ) { $input_frame_rate = `perl dfxpFrameRate.pl $input_file`; }
# if that didn't work, default to 60 fps
if ( $input_frame_rate eq undef ) { $input_frame_rate = 60; }
chomp( $input_frame_rate );

#print "File: $input_file\n";
#print "Input Frame Rate: $input_frame_rate\n";
#print "Output Frame Rate: $output_frame_rate\n";

my $scale_factor = $input_frame_rate / $output_frame_rate;
# print "Scale Factor: $scale_factor\n";

while ( my $line = <$fh> ) {
	chomp( $line );
	
	if ( $line =~ /^(.*?)(begin=\"[0-9]{2}:[0-9]{2}:[0-9]{2}:)([0-9]{2})(\")(.*?)$/ ) {
		# scale the frame number by our calculated scale factor
		# round down towards zero by dropping fractional part using int()
		$adjusted_frame = int( $3 * $scale_factor );
		
		# if the frame number is less than 10, add a leading zero
		if ( $adjusted_frame < 10 ) { $adjusted_frame = "0$adjusted_frame"; }
		
#		print "Initial Frame: $3\tAdjusted Frame: $adjusted_frame\n";
		
		$line = "$1$2$adjusted_frame$4$5";
	}

	if ( $line =~ /^(.*?)(end=\"[0-9]{2}:[0-9]{2}:[0-9]{2}:)([0-9]{2})(\")(.*?)$/ ) {
		# scale the frame number by our calculated scale factor
		# round down towards zero by dropping fractional part using int()
		$adjusted_frame = int( $3 * $scale_factor );
		
		# if the frame number is less than 10, add a leading zero
		if ( $adjusted_frame < 10 ) { $adjusted_frame = "0$adjusted_frame"; }
		
#		print "Initial Frame: $3\tAdjusted Frame: $adjusted_frame\n";
		
		$line = "$1$2$adjusted_frame$4$5";
		
	}
	
	
	if ( $line =~ /^(.*?)(dur=\"[0-9]{2}:[0-9]{2}:[0-9]{2}:)([0-9]{2})(\")(.*?)$/ ) {
		# scale the frame number by our calculated scale factor
		# round down towards zero by dropping fractional part using int()
		$adjusted_frame = int( $3 * $scale_factor );
		
		# if the frame number is less than 10, add a leading zero
		if ( $adjusted_frame < 10 ) { $adjusted_frame = "0$adjusted_frame"; }
		
#		print "Initial Frame: $3\tAdjusted Frame: $adjusted_frame\n";
		
		$line = "$1$2$adjusted_frame$4$5";
		
	}
	
	
	
	
 	print "$line\n";
}

close( $fh );
