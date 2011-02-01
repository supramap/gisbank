#!/usr/bin/perl


# File is of the format:
#  node
#  node
#  weight 

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
	my ($current_node, $num_elts, @elt_list) = @_;
	#print "$current_node $num_elts @elt_list\n";
	my @node_list;
	my @cumulative_depth;
	for ($i=0;$i<$num_elts;$i++){
		$node_list[$i] = $elt_list[$i];
	}
	for ($i=0;$i<$num_elts;$i++){
		$cumulative_depth[$i] = $elt_list[$num_elts + $i];
	}
	$sofar = ",";
	for ($i=0;$i<=$#node_list;$i++){
		$dist = $cumulative_depth[$i] + $weights{$node_list[$i]}/2 + $weights{$current_node}/2;
		$error = sqrt(1/12 * $weights{$node_list[$i]} * $weights{$node_list[$i]} + 1/12 * $weights{$current_node} * $weights{$current_node});
		print "$node_list[$i],$current_node $sofar $dist $error\n"; 
		$sofar.= $node_list[$i] . ","; 	
	} 

	for ($i=0;$i<=$#cumulative_depth;$i++){
		$cumulative_depth[$i] += $weights{$current_node}; 
	}
	unshift @node_list, $current_node;
	unshift @cumulative_depth, 0;	
	if (exists($child1{$current_node})){
		&recursedowntree($child1{$current_node},$num_elts+1,@node_list,@cumulative_depth);
	}
	if (exists($child2{$current_node})){
		&recursedowntree($child2{$current_node},$num_elts+1,@node_list,@cumulative_depth);
	}
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
foreach $pairing (keys %weights){
	$dist = $weights{$pairing} / 3; 
	$error = sqrt($weights{$pairing} * $weights{$pairing} / 6);
	print "$pairing,$pairing , $dist $error\n"; 
}

# Now we start at the root, and recurse down.
&recursedowntree($child1{$rootname},0,(),());
&recursedowntree($child2{$rootname},0,(),());
