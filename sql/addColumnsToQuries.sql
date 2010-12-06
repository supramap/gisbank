alter table queries 
add job_id int default 0, 
add kml_status int default 0

alter table isolates
add pathogen varchar(20)

update isolates
set pathogen = 'H5N1'
where virus_type ='A / H5N1'

update isolates
set pathogen = 'H1N1 (Unkown)'
where virus_type ='A / H1N1'
#and h1n1_swine_set <> 'Seasonal'
#and h1n1_swine_set <> 'Pandemic'

update isolates
set pathogen = 'H1N1 (Pandemic)'
where virus_type ='A / H1N1'
and h1n1_swine_set ='Pandemic'

update isolates
set pathogen = 'H1N1 (Seasonal)'
where virus_type ='A / H1N1'
and h1n1_swine_set = 'Seasonal'



