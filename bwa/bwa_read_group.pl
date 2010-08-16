#!/usr/bin/perl

use warnings;
use strict;
use IO::File;
use Getopt::Long;

#
# BWA read group adder/wrapper
# Ben Oberkfell & The Genome Center at Washington University
#
# USAGE:  bwa_read_group_tag.pl --read-group-id=12345 --sample=SAMPLE_NAME --library=LIBRARY_NAME -- bwa sampe...
#
# This adds the bare minimum read group header information necessary for tagging reads
# with the library from whence they came (useful for SV detection, Picard library-based
# deduplication, etc).
#
# No warranty expressed or implied, this code is provided "as is."
#
######################################################################################

my $rg_id;
my $sample;
my $library;

my $res = GetOptions("read-group-id=s" => \$rg_id,
		     "sample=s", => \$sample,
		     "library=s", => \$library,
	           	);

if ((!$rg_id && !$sample && !$library) || @ARGV == 0) {
	die "ERROR:  USAGE: bwa_read_group.pl --read-group-tag=XXXXX --sample=samp --library=samp-lib1 -- bwa sampe ...";
}

if(!$rg_id) {
	die "ERROR:  You must specify a read group id with --read-group-id=XXXXX";
}

if(!$sample) {
	die "ERROR:  You must specify a sample with --sample=XXXXX";
}

if(!$library) {
	die "ERROR:  You must specify a library with --library=XXXXX";
}

my $bwa_args = join " ", @ARGV;

my $bwa_fh = IO::File->new("$bwa_args|") || die "Can't open bwa with $bwa_args $!";

my $first_line = 1;
my $printed_rg = 0;
while (my $line = $bwa_fh->getline) {
	if ( substr($line,0,1) ne '@') {
		if ($first_line && $printed_rg == 0) {
			printf("\@RG\tID:%s\tSM:%s\tLB:%s\n", $rg_id, $sample, $library);
			$printed_rg = 1;
			$first_line = 0;
		}
		chomp $line;	
		print $line."\tRG:Z:$rg_id\n";
	} else {
		print $line;
	}
}
