{split($1,a,","); key = a[1]; code = a[2]; tweight = a[3];} (ARGIND == 1){twdex[key] = tweight;} /^\*/{nextfile;} (ARGIND==2){cweight[key]+=twdex[code]; print $1 " " $2 " " cweight[key] " " $4;}
