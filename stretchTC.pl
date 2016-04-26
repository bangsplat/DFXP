#!/usr/bin/perl
use strict;	# Enforce some good programming rules

#
# stretchTC.pl
# version 0.1
# 
# created 2016-04-26
# modified 2016-04-26
# 
# created by Theron Trowbridge
# 
# apply drop/non-drop stretch to a timecodes
#

my ( $input_HR, $input_MIN, $input_SEC, $input_FR );
my ( $output_HR, $output_MIN, $output_SEC, $output_FR );
my ( $input_MILI, $output_MILI, $leftover_MILI );
my $input_TC = $ARGV[0];
my $output_TC;
my $frame_rate = 30;	## global variable

$input_MILI = TCToMili( $input_TC );

## OK, so to do a stretch, we can multiply by 1001/1000 on miliseconds and convert back to timecode
## right?
## probably need to make sure it's a proper drop frame timecode when we get done to be safe
$output_MILI = $input_MILI * (1001/1000);

$output_TC = miliToTC( $output_MILI );

#####
print "$output_TC\n";
#####

### OK, so now we should check to make sure the final frame is a valid drop frame timecode
### even if the output is not DFTC, it's better to be safe than sorry
### and delaying by two frames is not going to kill anyone


sub TCToMili {
	my $tc = shift( @_ );
	my $mili;
	
	$tc =~ /^([0-9]{2}):([0-9]{2}):([0-9]{2})[:;]([0-9]{2})/;
	
	$mili = ( $1 * 3600 * 1000 ) + ( $2 * 60 * 1000 ) + ( $3 * 1000 ) + ( ( $4 / $frame_rate ) * 1000 );
	
	return( $mili );
}

sub miliToTC {
	my $mili = shift( @_ );
	my $tc;
	my $digit;
	
	# hours
	$digit = int( $mili / ( 3600 * 1000 ) );
	$mili -= $digit * ( 3600 * 1000 );
	if ( $digit < 10 ) { $tc .= "0$digit:" } else { $tc .= "$digit:" };
	
	# minutes
	$digit = int( $mili / ( 60 * 1000 ) );
	$mili -= $digit * ( 60 * 1000 );
	if ( $digit < 10 ) { $tc .= "0$digit:" } else { $tc .= "$digit:" };
	
	# seconds
	$digit = int( $mili / 1000 );
	$mili -= $digit * 1000;
	if ( $digit < 10 ) { $tc .= "0$digit:" } else { $tc .= "$digit:" };
	
	# frames
	$digit = int( ( $mili / 1000 ) * $frame_rate );
	if ( $digit < 10 ) { $tc .= "0$digit" } else { $tc .= "$digit" };
	
	return( $tc );
}




# 
# 
# my $input_file = $ARGV[0];
# # my $output_frame_rate = $ARGV[1];
# # my $input_frame_rate = $ARGV[2];
# my $adjusted_frame;
# 
# if ( $input_file eq undef ) { die "stretchDFXP.pl <filename>\n\nPlease specify an input file\n"; }
# open( my $fh, '<', $input_file ) or die "Can't open file $input_file $!";
# 
# 
# 
# 
# 
# # if ( $output_frame_rate eq undef ) { $output_frame_rate = 24; }
# 
# # if input frame rate not specified, try to guess what it is
# if ( $input_frame_rate eq undef ) { $input_frame_rate = `perl dfxpFrameRate.pl $input_file`; }
# # if that didn't work, default to 60 fps
# if ( $input_frame_rate eq undef ) { $input_frame_rate = 60; }
# chomp( $input_frame_rate );
# 
# #print "File: $input_file\n";
# #print "Input Frame Rate: $input_frame_rate\n";
# #print "Output Frame Rate: $output_frame_rate\n";
# 
# my $scale_factor = $input_frame_rate / $output_frame_rate;
# # print "Scale Factor: $scale_factor\n";
# 
# while ( my $line = <$fh> ) {
# 	chomp( $line );
# 	
# 	if ( $line =~ /^(.*?)(begin=\"[0-9]{2}:[0-9]{2}:[0-9]{2}:)([0-9]{2})(\")(.*?)$/ ) {
# 		# scale the frame number by our calculated scale factor
# 		# round down towards zero by dropping fractional part using int()
# 		$adjusted_frame = int( $3 * $scale_factor );
# 		
# 		# if the frame number is less than 10, add a leading zero
# 		if ( $adjusted_frame < 10 ) { $adjusted_frame = "0$adjusted_frame"; }
# 		
# #		print "Initial Frame: $3\tAdjusted Frame: $adjusted_frame\n";
# 		
# 		$line = "$1$2$adjusted_frame$4$5";
# 	}
# 
# 	if ( $line =~ /^(.*?)(end=\"[0-9]{2}:[0-9]{2}:[0-9]{2}:)([0-9]{2})(\")(.*?)$/ ) {
# 		# scale the frame number by our calculated scale factor
# 		# round down towards zero by dropping fractional part using int()
# 		$adjusted_frame = int( $3 * $scale_factor );
# 		
# 		# if the frame number is less than 10, add a leading zero
# 		if ( $adjusted_frame < 10 ) { $adjusted_frame = "0$adjusted_frame"; }
# 		
# #		print "Initial Frame: $3\tAdjusted Frame: $adjusted_frame\n";
# 		
# 		$line = "$1$2$adjusted_frame$4$5";
# 		
# 	}
# 	
# 	
# 	if ( $line =~ /^(.*?)(dur=\"[0-9]{2}:[0-9]{2}:[0-9]{2}:)([0-9]{2})(\")(.*?)$/ ) {
# 		# scale the frame number by our calculated scale factor
# 		# round down towards zero by dropping fractional part using int()
# 		$adjusted_frame = int( $3 * $scale_factor );
# 		
# 		# if the frame number is less than 10, add a leading zero
# 		if ( $adjusted_frame < 10 ) { $adjusted_frame = "0$adjusted_frame"; }
# 		
# #		print "Initial Frame: $3\tAdjusted Frame: $adjusted_frame\n";
# 		
# 		$line = "$1$2$adjusted_frame$4$5";
# 		
# 	}
# 	
# 	
# 	
# 	
#  	print "$line\n";
# }
# 
# close( $fh );
