(ARGIND==1 && !/:/){
	tw += 0.01;
}

(ARGIND==1 && /:/){
	for (i=2;i<=NF;i++){
		tw++;
		w[$i]++;
	}
}

(ARGIND==2 && /,/){
	split ($0,a,","); 
	print a[1] "," a[2] "," w[a[1]]/tw;
}

(ARGIND==2 && !/,/){
	print;
}
