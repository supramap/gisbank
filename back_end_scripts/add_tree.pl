#!/usr/bin/perl

$treestr = <STDIN>;
chomp $treestr;
$cptr = 0;

sub ACCTRANS{
	my $this_node = $_[0];
	foreach $this_character (keys %{$state{$this_node}}){
		if (length(${$state{$this_node}}{$this_character}) > 1){
			if (exists($ancestor{$this_node})){
				${$state{$this_node}}{$this_character} = ${$state{$ancestor{$this_node}}}{$this_character};
			} else {
				${$state{$this_node}}{$this_character} = substr(${$state{$this_node}}{$this_character},0,1);
			}
		} else {
			if (exists($ancestor{$this_node}) && ${$state{$this_node}}{$this_character} ne ${$state{$ancestor{$this_node}}}{$this_character}){
				$apostring = "id=\"$this_character\" change=\"";
				$apostring.= ${$state{$ancestor{$this_node}}}{$this_character};
				$apostring.= " -> ";
				$apostring.= ${$state{$this_node}}{$this_character};
				$apostring.= "\"";
				push @{$apmorphy_list{$this_node}},$apostring;
			}
		}
		
	}

	if (exists($child1{$this_node})){&ACCTRANS($child1{$this_node});}
	if (exists($child2{$this_node})){&ACCTRANS($child2{$this_node});}
}


while ($cptr < length($treestr)){
	if (substr($treestr,$cptr,1) !~ /[\)\(,:]/){
		$cptr++;
	}

	if (substr($treestr,$cptr,1) =~ /[,\(]/){
		$cptr++;
		$tmpstring = "";
		while (substr($treestr,$cptr,1) !~ /[\)\(,:]/){
			$tmpstring .= substr($treestr,$cptr,1);
			$cptr++;
		}
		if ($tmpstring eq ""){
			$num_internal++;
			$tmpstring = $num_internal;
		} else {
			$isleaf{$tmpstring} = 1;
		}
		push @nodenames, $tmpstring;
	}

	if (substr($treestr,$cptr,1) =~ /[\)]/){
		$cptr++;
		$oldchild1 = pop @nodenames;
		$weight1 = pop @nodeweights;
		$oldchild2 = pop @nodenames;
		$weight2 = pop @nodeweights;
		$parent = $nodenames[$#nodenames];
		if ($parent eq ""){
			$parent = 0;
		}
		$oldweights{$oldchild1} = $weight1;
		$oldweights{$oldchild2} = $weight2;
		$oldparent{$oldchild1} = $parent;
		$oldparent{$oldchild2} = $parent;
	}

	if (substr($treestr,$cptr,1) =~ /:/){
		$cptr++;
		$tmpstring = "";
		while (substr($treestr,$cptr,1) =~ /[0-9\.]/){
			$tmpstring .= substr($treestr,$cptr,1);
			$cptr++;
		}
		push @nodeweights, $tmpstring;
	}
}

# Done reading the tree.
while (<STDIN>){
	chomp;
	$backbuf[0] = $backbuf[1];
	$backbuf[1] = $backbuf[2];
	$backbuf[2] = $backbuf[3];
	$backbuf[3] = $_;
	# This lets us know we have started a new block of character states.
	if (/Children:/){
		@childs = split;
		$parent = $backbuf[0];
		$parent =~ s/\s//g;
		if ($childs[1] ne ""){
			$child1{$parent} = $childs[1];
			$child2{$parent} = $childs[2];
			$ancestor{$childs[1]} = $parent; 
			$ancestor{$childs[2]} = $parent; 
		}
	}
	if (/Final/){
		@line = split;
		$tmpstate = substr($line[6],1,length($line[6])-3);
		if ($tmpstate eq "absent"){$tmpstate = "+";}
		if ($tmpstate eq "present"){$tmpstate = "-";}
		${$state{$parent}}{$line[0]} = $tmpstate; 
	} 
}

# Start at the leaves, and propogate up all weigts
foreach $child (keys %isleaf){
#	$newweight{$child} = $oldweight{$child};
	$map{$child} = $child;
	$padre = $child;
	while (exists($ancestor{$padre}) && !exists($newweight{$ancestor{$padre}})){
		$map{$ancestor{$padre}} = $oldparent{$map{$padre}}; 
		$padre = $ancestor{$padre};
	}
}

# Start at the root, and resolve all apomorphies by ACCTRAN
&ACCTRANS("root");

# Now print out the actual results.
foreach $child (keys %ancestor){
	print "$child,$ancestor{$child},$oldweights{$map{$child}}\n";
	foreach $transform(@{$apomorphy_list{$child}}){
		$transformlist{$transform}.= " $child";
	}
#	print "<node>\n";
#	print "<id>$child</id>\n";
#	print "<weight>$oldweights{$map{$child}}</weight>\n";
#	print "<transformations>\n";
#	foreach $transform (@{$apmorphy_list{$child}}){
#		print "<transformation $transform/>\n";
#	}
#	print "</transformations>\n";
#	print "<ancestors>\n";	
#	print "<ancestor";
#	print " ";
#	print "id=\"$ancestor{$child}\" type=\"node\"/>\n";
#	print "</ancestors>\n";	
#	print "</node>\n";
}

print "*****\n";

foreach $character (keys %transformlist){
	print "$character $transformlist{$character}\n";
}
