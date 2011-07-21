class PoyJob < ActiveRecord::Base

  def addpoyfile(job_name, sequence_length)

    # if 100 limit the total / 2 times will max at 83 hours
    # if 300 limit the total / 20 times will max at 75 hours
    # if 500 limit the total / 50 times will max at 83 hours
    self.search_time = ((sequence_length * sequence_length)/3000).ceil+2

    if (self.search_time>60)
      self.search_time=60;
    end

    if (self.search_time>5 && self.resource == 'superdev')
      self.search_time=5;
    end

    @hours = self.search_time.div(60);
    @minutes = self.search_time.modulo(60);

      #Dan now wants 2 minute search time and 5 minute wall time regardless of the size of the data set. This will bomb on most datasets
    @hours = 0
    @minutes =2


#name = Query.find(self.query_id).name.gsub(" ","")
    self.poy =
        "read (\"#{job_name.gsub(" ", "")}.fasta\")
set(root:\"#{Sequence.find(self.outgroup).accession}\")
search(max_time:00:#{@hours}:#{@minutes}, memory:gb:2)
select(best:1)
transform(tcm:(1,2),gap_opening:1)
report (\"#{job_name.gsub(" ", "")}.kml\", kml:(supramap, \"#{job_name.gsub(" ", "")}.csv\"))
report (\"#{job_name.gsub(" ", "")}.ia\", ia)
report (\"#{job_name.gsub(" ", "")}_stats.txt\", searchstats)
report (\"#{job_name.gsub(" ", "")}.tre\", trees)
exit ()
"
    #transform (static_approx)
    #report (\"#{job_name.gsub(" ","")}.ia\", ia) returns blank
    #report (\"#{job_name.gsub(" ","")}.ia\", ia:\"#{job_name.gsub(" ","")}.fasta\") error:[identifiers] expected after ":" (in [report_argument])
  end

  def submit
    if (self.resource == 'glenn')
      node_number= 20
    else
      node_number=8
    end
    self.service_job = Poy_service.init(self.resource)
    self.save

    name = Query2.find(self.query_id).name.gsub(" ", "")
    Poy_service.add_text_file(self.service_job, "#{name}.fasta", self.fasta)
    Poy_service.add_text_file(self.service_job, "#{name}.csv", self.geo)
    Poy_service.add_text_file(self.service_job, "run.poy", self.poy)
      #results = Poy_service.submit_poy(self.service_job,self.search_time*20 ,10)
    results = Poy_service.submit_poy(self.service_job, 60, node_number)
    output =(results=="Success")
    if (output)
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

  def isdone id
    debug = File.new('log/debug2.txt', "a")
    debug.write "\n\n\nstarted is done #{Time.now}\n"; debug.flush
    poy_job = PoyJob.find(id)

    if (poy_job.status == 2)
      return true
    end

    debug.write "found poy job #{Time.now}\n"; debug.flush
    output = Poy_service.is_done_yet(poy_job.service_job)
    debug.write "ran service #{Time.now}\n"
    if (output)
      debug.write "*** loading poy job files #{Time.now}\n"; debug.flush
      name = Query2.find(poy_job.query_id).name.gsub(" ", "")
      debug.write "found name #{Time.now}\n"; debug.flush
      begin
        poy_job.aligned_fasta = Poy_service.get_file(poy_job.service_job, "#{name}.ia")
        debug.write "load ia #{Time.now}\n"
      rescue
        debug.write "failed to load ia #{Time.now}\n"
      end

      begin
        poy_job.kml = Poy_service.get_file(poy_job.service_job, "#{name}.kml")
        debug.write "loaded kml #{Time.now}\n"; debug.flush
      end

      begin
        poy_job.output = Poy_service.get_file(poy_job.service_job, "#{name}_stats.txt")
      end

      begin
        poy_job.tree = Poy_service.get_file(poy_job.service_job, "#{name}.tre")
      end

      begin
        poy_job.poy_output = Poy_service.get_file(poy_job.service_job, "output.txt")
      end
      poy_job.status = 2
      poy_job.save
      Poy_service.delete(poy_job.service_job)
    end
    debug.write "finished #{Time.now}\n"; debug.flush; debug.close
    return output
  end

# def isdone
#
#
#    output =  Poy_service.is_done_yet(self.service_job)
#    if(output)
#      name = Query2.find(self.query_id).name.gsub(" ","")
#
#      begin
#
#        ia_s ='';                                            -
#        ia_s = Poy_service.get_file(self.service_job,"#{name}.ia")
#        if(ia_s)
#            self.aligned_fasta = ia_s.split("\n")[8..-1].join("\n")
#        end
#
#      rescue
#
#
#      end
#
#     self.kml = Poy_service.get_file(self.service_job,"#{name}.kml")
#     self.output = Poy_service.get_file(self.service_job,"#{name}_stats.txt")
#     self.tree = Poy_service.get_file(self.service_job,"#{name}.tre")
#     self.poy_output = Poy_service.get_file(self.service_job,"output.txt")
#     self.status = 2
#     self.save
#     Poy_service.delete(self.service_job)
#    end
#   return output
# end

end
