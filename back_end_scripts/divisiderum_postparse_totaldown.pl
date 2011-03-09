#!/usr/bin/perl


# File is of the format:
#  node
#  node
#  weight 

# We want to produce *two* classes of output.
#  The first class of output is of the following form:
#  W node total_descendent_weight minimal_weight
#
#  The second class of output is of the following form:
#  D node node
#  And only contains entries where node2 is a descendent of node1.


#### OLD SPECS BELOW
# We want to produce output in the form:
# node node distance error

# But *only* if the first node is an ancestor of the second node.

# Issue:
#  changes are on the *parent edge*
#  so if you have this:
#  A
#   \
#    B
#   / \
#  C   D
#  The distance from (C,C) is based on C alone.
#  The distance from (C,B) is based on C and B.

sub recursedowntree{
	my ($current_node, @ancestor_list) = @_;
	push @ancestor_list, $current_node;
	foreach $other_node (@ancestor_list){
		print "D,$other_node,$current_node\n";
		}
	my $depth = $weights{$current_node} / 2;
	if (exists $child1{$current_node}){
		$depth += &recursedowntree($child1{$current_node},@ancestor_list);
	} 
	if (exists $child2{$current_node}){
		$depth += &recursedowntree($child2{$current_node},@ancestor_list);
	}
	my $mdepth = $weights{$current_node} / 3;
	print "W,$current_node,$depth,$mdepth\n";
	$depth += $weights{$current_node} / 2;
	return $depth; 
}

$rootname = $ARGV[0];

open EDGEFILE, $ARGV[1] or die "file not found!\n";

while (<EDGEFILE>){
	last if (substr($_,0,1) eq "*");
	chomp;
	@line = split /,/;
	$weights{$line[0]} = $line[2];
	$parent{$line[0]} = $line[1];
	if (exists($child1{$line[1]})){
		$child2{$line[1]} = $line[0];} else
	{$child1{$line[1]} = $line[0];}
}

# Special case for self-edge distances
#foreach $pairing (keys %weights){
#	$dist = $weights{$pairing} / 3; 
#	$error = sqrt($weights{$pairing} * $weights{$pairing} / 6);
#	print "$pairing,$pairing , $dist $error\n"; 
#}

# Now we start at the root, and recurse down.
&recursedowntree($child1{$rootname},());
&recursedowntree($child2{$rootname},());
