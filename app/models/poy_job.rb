class PoyJob < ActiveRecord::Base

 def addpoyfile(job_name,sequence_length)

    # if 100 limit the total / 2 times will max at 83 hours
    # if 300 limit the total / 20 times will max at 75 hours
    # if 500 limit the total / 50 times will max at 83 hours
    self.search_time = ((sequence_length * sequence_length )/3000).ceil+2

     if(self.search_time>60)
       self.search_time=60;
     end

      @hours = self.search_time.div(60);
      @minutes = self.search_time.modulo(60);
#name = Query.find(self.query_id).name.gsub(" ","")
     self.poy =
"read (\"#{job_name.gsub(" ","")}.fasta\")
set(root:\"#{Sequence.find(self.outgroup).accession}\")
search(max_time:00:#{@hours}:#{@minutes}, memory:gb:2)
select(best:1)
report (\"#{job_name.gsub(" ","")}.kml\", kml:(supramap, \"#{job_name.gsub(" ","")}.csv\"))
report (\"#{job_name.gsub(" ","")}.ia\", ia)
report (\"#{job_name.gsub(" ","")}_stats.txt\", searchstats)
report (\"#{job_name.gsub(" ","")}.tre\", trees)
exit ()
"
#transform (static_approx)
#report (\"#{job_name.gsub(" ","")}.ia\", ia) returns blank
#report (\"#{job_name.gsub(" ","")}.ia\", ia:\"#{job_name.gsub(" ","")}.fasta\") error:[identifiers] expected after ":" (in [report_argument])
 end

 def submit
 self.service_job = Poy_service.init
 name = Query.find(self.query_id).name.gsub(" ","")
 Poy_service.add_text_file(self.service_job,"#{name}.fasta", self.fasta)
 Poy_service.add_text_file(self.service_job,"#{name}.csv", self.geo)
 Poy_service.add_text_file(self.service_job,"run.poy", self.poy)
 results = Poy_service.submit_poy(self.service_job,self.search_time*10 )
 output =(results=="Success")
 if(output)
   self.status = 1
 end
 self.save
 return output

    #Poy_service.add_text_file(@job_id,"#{@query.name}.csv", @query.make_geo)
    #Poy_service.add_poy_file(@job_id,"#{@query.name}",@search_minutes)
    #results = Poy_service.submit_poy(@job_id,@total_minutes )

    #if(results=="Success")

      #@query.kml_status =1
      #@query.job_id = @job_id
      #@query.save
    #else
    #  flash[:notice] = "Failed to submit poy:#{results}"
    #end
 end

 def isdone
    output =  Poy_service.is_done_yet(self.service_job)
    if(output)
      name = Query.find(self.query_id).name.gsub(" ","")
     self.aligned_fasta = Poy_service.get_file(self.service_job,"#{name}.ia")
     self.kml = Poy_service.get_file(self.service_job,"#{name}.kml")
     self.output = Poy_service.get_file(self.service_job,"#{name}_stats.txt")
     self.tree = Poy_service.get_file(self.service_job,"#{name}.tre")
     self.poy_output = Poy_service.get_file(self.service_job,"output.txt")
     self.status = 2
     self.save
     Poy_service.delete(self.service_job)
    end
   return output
 end

end
