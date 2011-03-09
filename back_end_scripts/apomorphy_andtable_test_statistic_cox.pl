#!/usr/bin/perl

# This script reads in a table of apomorphies (in xml format) and a table of internode distances, and spits out some stats on each pair of apomorphies.

# Takes no "arguments", I'm lazy so I just used globals.

sub teststat_dists{
		# OKAY!  Major change in this version.
		#  Ancestral edges ($edge1) are sorted in *ascending* order of weight.
		#  Descendent edges ($edge2) are sorted in *descending* order of weight.
		#   As ancestral edges are processed, they are pushed onto a default list, replacing any of their own descendents.
		#   
 		#   Then, starting from that default list, the unused descendent edges are pushed into the list.
		#   
		@templist1 = sort {$masterweight{$a} <=> $masterweight{$b} || $a cmp $b} @{$apolists{$list1}};

		@templist2p = ();
		#print "LIST1 @templist1\n";

		foreach $edge1 (@{$apolists{$list1}}){
			push @templist2p, "I" . $edge1; 
		}
		#print "LIST2 @templist2p\n";
		
		foreach $edge2 (@{$apolists{$list2}}){
			push @templist2p, "D" . $edge2; 
		}
		#print "LIST2 @templist2p\n";

		@templist2 = sort {$masterweight{substr($b,1)} <=> $masterweight{substr($a,1)} || substr($a,1) cmp substr($b,1) || $b cmp $a} @templist2p;
		#@templist2 = sort {$masterweight{substr($b,1)} <=> $masterweight{substr($a,1)}} @templist2p; 
		%templistdex = ();

		#print "LIST @templist2\n";

		$qt = 0;
		foreach $edge2 (@templist2){
			$qt++;
			if (substr($edge2,0,1) eq "I"){
				$templistdex{substr($edge2,1)} = $qt;
			}
		}

		%seen = ();
		$numdied = 0;
		$numcensored = 0;
		$numexpectedtodie = 0;
		$alldeaths = 0;
		@weightsagain = ();
		$remainingweight = 1;
		foreach $edge1 (@templist1){
			@descendentlist = ();
			$dies = 0;
			$currentweight = $masterweight{$edge1};	
			for ($qt = $templistdex{$edge1}; $qt <= $#templist2; $qt++){
				$edge2 = substr($templist2[$qt],1);
				$status2 = substr($templist2[$qt],0,1); 
				if (!exists $seen{$edge2}){
					#First, check the existing descend list for ancestors of this sequence.
					foreach $refedge (@descendentlist){
						if (exists $ancestor_rel{$refedge . "," . $edge2}){
							$seen{$edge2} = 1;
							}
					}
					if (!exists $seen{$edge2}){
						if (exists $ancestor_rel{$edge1 . "," . $edge2}){
							push @descendentlist, $edge2;
							if ($status2 eq "D"){
								$dies++;
							}
						$currentweight-=$masterweight{$edge2};
						}
					} 
				} 
			}		
			$alldeaths+=$dies;
			if ($dies > 0){
				$numdied++;
			} else {
				$numcensored++;
			}
			if ($currentweight < $minweight{$edge1}){$currentweight = $minweight{$edge1};}
			$numexpectedtodie += 1 - exp(-1 * $currentweight * ($#{$apolists{$list2}} + 1));
			push @weightsagain, $currentweight;
			$remainingweight -= $currentweight;
		} 
		print "$list1\t$printstr\t";
		print "$numdied\t$numcensored\t$numexpectedtodie\t";
		print $#{$apolists{$list1}}+1;
		print "\t";
		print $#{$apolists{$list2}}+1;
		print "\t";
		$numexpectedtodie = 0;
		foreach $currentweight (@weightsagain){
			$numexpectedtodie += 1 - exp(-1 * $currentweight * ($#{$apolists{$list2}} + 1.5 - $alldeaths) / $remainingweight);
		}	
		print "$alldeaths\t$numcensored\t$numexpectedtodie\n";	
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

# MAJOR MAJOR REVISION!!!!
# This file now contaisn two classes of entries.
# One is for ancestor-descendent relations.
# The other is for total-descendent tree length. 
open DISTFILE, $ARGV[1] or die "file not found!\n";
while (<DISTFILE>){
	chomp;
	@line = split /,/;
	if (/^D/){
		$ancestor_rel{$line[1] . "," . $line[2]} = 1;
		#print "KEY1 $line[1] $line[2]\n";
	}

	if (/^W/){
		$minweight{$line[1]} = $line[3];
		$masterweight{$line[1]} = $line[2];
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
