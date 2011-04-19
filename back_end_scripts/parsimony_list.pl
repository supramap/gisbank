#!/usr/bin/perl

# For this, we will need:
#  1) Modify the script above to read in parents so we can can proceed along the tree.
#  2) Proceed through the tree and generate an exclsion tree.
#  3) Sample from these exclusion trees when we run the various calculations below.

# This takes three arguments.
#  1 - the *name of the root* (it's 0 in my test files)
#  2 - the processed tree file.
#  3 - the number of parsimonious sets to generate.

$rootname = $ARGV[0];

open EDGEFILE, $ARGV[1] or die "file not found!\n";
EDGEDONE: while (<EDGEFILE>){
	chomp;
	@line = split /,/;
#	push @nodenums, $line[0];
#	push @weight, $line[2];
#	push @weightdex1, $tweight;
#	$tweight += $line[2];
#	push @weightdex2, $tweight;
	if (substr($_,0,1) eq "*") {last EDGEDONE;}
	push @{$children{$line[1]}}, $line[0];
	$weights{$line[0]} = $line[2];
	if ($line[2] + 0 <= 0){$weights{$line[0]} = 0.000001;}
}

my %ineligible = ();

sub EdgeScrambler {
	$current_node = pop @_;
	if (exists($children{$current_node})){
		$nodea = ${$children{$current_node}}[0]; 
		$nodeb = ${$children{$current_node}}[1]; 
		if (!exists($ineligible{$current_node})){
			#print "FOO!$current_node\t$nodea\t$nodeb\n";
			$proba = $weights{$nodea} / ($weights{$nodea} + $weights{$current_node});
			$probb = $weights{$nodeb} / ($weights{$nodeb} + $weights{$current_node});
			if (rand() < $proba){$ineligible{$current_node} = 1;} else {$ineligible{$nodea} = 1;}
			if (rand() < $probb){$ineligible{$current_node} = 1;} else {$ineligible{$nodeb} = 1;}
		}
		&EdgeScrambler($nodea);
		&EdgeScrambler($nodeb);
	}
}

for ($numsets = 0; $numsets < $ARGV[2]; $numsets++){
	%ineligible = ();
	#print "$root\n";
	&EdgeScrambler(${$children{$rootname}}[0]);	
	&EdgeScrambler(${$children{$rootname}}[1]);	
	foreach $current_node (keys %weights){
		if (!exists($ineligible{$current_node})){
			print "$current_node,";
		}
	}
	print "\n";
}

