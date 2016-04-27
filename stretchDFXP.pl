#!/usr/bin/perl
use strict;	# Enforce some good programming rules

#
# stretchDFXP.pl
# version 0.3
# 
# created 2016-04-26
# modified 2016-04-27
# 
# created by Theron Trowbridge
# 
# apply drop/non-drop stretch to time codes in DFXP file
#
# file name is passed as first command line parameter
# input file frame rate is assumed to be 30 fps
# (can guess from input file)
#
# based partially on scaleDFXPFrameRate.pl
# 

my $FRAME_RATE = 30;		# global variable
my $input_file = $ARGV[0];
my ( $begin_tc, $end_tc );

if ( $input_file eq undef ) { die "stretchDFXP.pl <filename>\n\nPlease specify an input file\n"; }
open( my $fh, '<', $input_file ) or die "Can't open file $input_file $!";

# step through input file one line at a time
while ( my $line = <$fh> ) {
#	chomp( $line );
	
	if ( $line =~ /<\?xml/ ) {
		print "$line";
		print "<!-- Timecodes adjusted by stretchDFXP.pl -->\r";
		next;
	}
	
	$begin_tc = "";
	$end_tc = "";
	
	# if the line contains a begin= timecode, stretch it
	if ( $line =~ /begin=\"([0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2})\"/ ) {
		$begin_tc = stretchTC( $1 );
		$line =~ s/^(.*?begin=\")[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}(\".*?)$/$1$begin_tc$2/;
	}
	# if the line contains an end= timecode, stretch it
	if ( $line =~ /end=\"([0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2})\"/ ) {
		$end_tc = stretchTC( $1 );
		$line =~ s/^(.*?end=\")[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}(\".*?)$/$1$end_tc$2/;
	}
	
 	print "$line";
}

close( $fh );

sub stretchTC {
	my $tc_in = shift( @_ );
	my ( $mili_in, $mili_out, $tc_out );
	
	$mili_in = TCToMili( $tc_in );
	$mili_out = $mili_in * ( 1001/1000 );
	$tc_out = miliToTC( $mili_out );
	$tc_out = fixDFTC( $tc_out );
	
	return( $tc_out );
}

sub TCToMili {
	my $tc = shift( @_ );
	my $mili;
	
	$tc =~ /^([0-9]{2}):([0-9]{2}):([0-9]{2})[:;]([0-9]{2})/;
	
	$mili = ( $1 * 3600 * 1000 ) + ( $2 * 60 * 1000 ) + ( $3 * 1000 ) + ( ( $4 / $FRAME_RATE ) * 1000 );
	
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
	$digit = int( ( $mili / 1000 ) * $FRAME_RATE );
	if ( $digit < 10 ) { $tc .= "0$digit" } else { $tc .= "$digit" };
	
	return( $tc );
}

# fixDFTC()
#
# check to see if input timecode is a valid drop frame timecode
# if it is not, advance to the next valid timecode
#
# WHAT ARE THE RULES?
# frames 00 and 01 are skipped if
# 	the seconds are 00 (whole minute)
# BUT NOT IF
# 	the minutes are 10, 20, 30, 40, or 50
# 		(roughly every 10th minute, but not on full hour)
sub fixDFTC {
	my $tc = shift( @_ );
	
	$tc =~ /^([0-9]{2}):([0-9]{2}):([0-9]{2})[:;]([0-9]{2})/;
	
	if ( ( int( $4 ) == 0 ) || ( int( $4 ) == 1 ) ) {								# frames are zero or 1
		if ( int ( $3 ) == 0 ) {													# and seconds are zero
			if ( ( ( int( $2 ) / 10 ) != 0 ) && ( ( int( $2 ) % 10 ) != 0 ) ) {		# and minutes are NOT 10, 20, 30, 40, or 50
				$tc = "$1:$2:$3:02";												# make frames "02"
			}
		}
	}
	## this isn't ideal, but will ensure drop frame friendly timecodes
	
	return( $tc );
}

