#!/usr/bin/awk
# Usage:
#  awk -f add_arbitrary_weights.awk tree.tre > new_tree.tre 
BEGIN{
}

{	c = 1;
for (i=1;i<=length($1);i++){
	if (substr($1,i,1) == "," || substr($1,i,1) == ")"){
		printf ":" c;
		c++;
	}
	printf substr($1,i,1);
}}
