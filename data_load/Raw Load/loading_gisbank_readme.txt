
go to http://www.ncbi.nlm.nih.gov/genomes/FLU/Database/nph-select.cgi

set whatever paremeters you want.
use full sequence and nuclutide coding region

set custom defline arg to *********IMPORTANT*********************
>{accession} | {strain} | {segment} | {host} | {segname} | {serotype} | {country} | {cdslocation} | {year} | {month} | {day} | {taxname} | 

download the fasta file.

Then run the following script

ruby gisbank_load.rb whatever.fa
