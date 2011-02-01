#!/usr/bin/perl

# This script reads in a table of apomorphies (in xml format) and a table of internode distances, and spits out some stats on each pair of apomorphies.

# Takes no "arguments", I'm lazy so I just used globals.
sub teststat_dists{
		%seen1 = ();
		%seen2 = ();
		@pairs = ();
		$numseen1 = 0;
		$numseen2 = 0;
		$test1 = 0;
		$test2 = 0;
		foreach $edge1 (@{$apolists{$list1}}){
			foreach $edge2 (@{$apolists{$list2}}){
				$seen1{$edge1} = 0;
				$seen2{$edge2} = 0;
				$pushstring = $edge1 . "," . $edge2; 
				if (exists($distance{$pushstring})){
					push @pairs, $pushstring;
				}
		}}
		@sortedpairs = sort {$distance{$a} <=> $distance{$b}} (@pairs);
		print "$list1\t$printstr\t";
		$numdied = 0;
		$numcensored = 0;
		$numexpectedtodie = 0;
SORTDONE:	foreach $this_pair (@sortedpairs){
			#if ($numseen1 > $#{$apolists{$list1}} && $numseen2 > $#{$apolists{$list2}}){last SORTDONE;}
			($edge1,$edge2) = split /,/, $this_pair;
			if ($seen1{$edge1} + $seen2{$edge2} + 0 < 1){
				#$test1++;
				#$test2+=$distance{$this_pair};
				$numdied++;
				$numexpectedtodie += 1 - exp(-1 * $distance{$this_pair} * ($#{$apolists{$list2}} + 1));
				$seen1{$edge1}++;
				$numseen1++;
			}
			if ($seen2{$edge2} + 0 < 1){
				$seen2{$edge2}++;
				$numseen2++;
			}
		}		
		foreach $edge1 (@{$apolists{$list1}}){
			if ($seen1{$edge1} + 0 < 1){
				#$test2+=$max_radius{$edge1};
				$numcensored++;
				$numexpectedtodie += 1 - exp(-1 * $max_radius{$edge1} * ($#{$apolists{$list2}} + 1));
			}
		}
		print "$numdied\t$numcensored\t$numexpectedtodie\t";
		print $#{$apolists{$list1}}+1;
		print "\t";
		print $#{$apolists{$list2}}+1;
		print "\n";
		#print "DONE CHAR\n";
}

# First, we read in the table of transformations which is in xml format
open APOMFILE, $ARGV[0] or die "file not found!\n";
$apomode = 0;
while (<APOMFILE>){
	chomp;
	if ($apomode == 1){
		@this_apolist = split;
		$charname = shift @this_apolist;
		@{$apolists{$charname}} = @this_apolist;
	} else {
	}
	if (substr($_,0,1) eq "*") {$apomode = 1;}
}

# Second, we load in the table of inter-edge distances.
# NOTE - with a flag, and alternate version of the script will want to read in the tree as well, and use that to exclude non-descendent distances!
open DISTFILE, $ARGV[1] or die "file not found!\n";
while (<DISTFILE>){
	chomp;
	@line = split;
	@items = split /,/, $line[0];
	if (!exists($distance{$line[0]}) || $line[2] < $distance{$line[0]}){
		$distance{$items[0] . "," . $items[1]} = $line[2];
		if ($line[2] > $max_radius{$items[0]}) {$max_radius{$items[0]} = $line[2];}
		#$censor_radius{$items[0]} += $line[2];
	}
}
close DISTFILE;


if ($ARGV[2]){
	open TESTSFILE, $ARGV[2];
	$apomode = 0;
	while (<TESTSFILE>){
		chomp;
		if ($apomode == 1){
			@line = split /,/;
			$list1 = $line[0];
			$list2 = "empty_val";
			$printstr = $line[1] . "_" . $line[2] . "_" . $line[3]; 
			@{$apolists{$list2}} = ();
			for ($i=4;$i<=$#line;$i++){
				push @{$apolists{$list2}}, $line[$i];
			}
			&teststat_dists();
		} else {
		}
		if (substr($_,0,1) eq "*") {$apomode = 1;}
	}
	close TESTFILE; 
} else {
	foreach $list1 (keys %apolists){
		foreach $list2 (keys %apolists){
			$printstr = $list2;
			&teststat_dists();
		}
	} 
}
