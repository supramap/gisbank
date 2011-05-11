class Poy
  def initialize(job)
    job.service_id = PoyService.init
    job.status = "starting poy service"
    job.save

    begin

      @poy_script =""
      fasta = JobFile.where("file_type = 'fas' and job_id=#{job.id}")[0]
      PoyService.add_text_file(job.service_id,fasta.name,fasta.data)
      #PoyService.add_file(job.service_id,fasta.name,fasta.data)
      if(job.prealigned_fasta)
        fasta[:file_type]="ia"
        fasta.save
        @poy_script <<"read(prealigned:(\"#{fasta.name}\",tcm:(1,2)))\n"
        @poy_script <<"set (root:\"#{job.outgroup}\")\n"
     else
        @poy_script <<"read (\"#{fasta.name}\")\n"
        @poy_script <<"set (root:\"#{job.outgroup}\")\n"
        @poy_script <<"transform (tcm:(1, 2))\n"
      end

      if(job.supplied_tree)
        tree= JobFile.where("file_type = 'tre' and job_id=#{job.id}")[0]
        PoyService.add_text_file(job.service_id,tree.name,tree.data)

        @poy_script << "read(\"#{tree.name}\")\n"
        @poy_script << "transform(static_approx)\n"
      else

        @poy_script << "search(max_time:00:0:5, memory:gb:2)\n"
        #@poy_script << "search(max_time:00:0:2, memory:gb:2)\n"
        #@poy_script << "search(max_time:00:0:2, memory:gb:2)\n"
        @poy_script << "transform(static_approx)\n"
        @poy_script << "select(best:1)\n"
        @poy_script << "report (\"#{job.name}.tre\", trees)\n"
      end

      if(!job.prealigned_fasta)
         @poy_script << "report (\"#{job.name}.ia\", ia)\n"
      end

      @poy_script << "report(\"#{job.name}.poy_output\",data,diagnosis)\n"
      @poy_script << "exit()\n"
      @poy_file = JobFile.new(:job_id =>job.id, :file_type=>"poy",:name => job.name+".poy",  :data => @poy_script)
      @poy_file.save
      PoyService.add_text_file(job.service_id,@poy_file.name,@poy_file.data)

       job.status = "uploaded all poy files"
       job.save

      PoyService.submit_poy(job.service_id)

      while(! PoyService.is_done_yet(job.service_id))
            sleep(30)
      end


        job.status = "Finished Running Poy"
         job.save

      #poy_output = PoyService.get_file(job.service_id,"#{job.name}.poy_output")
      poy_output = PoyService.get_zip_file(job.service_id,"#{job.name}.poy_output")
      JobFile.new(:job_id => job.id, :file_type=>"poy_out",:name => "#{job.name}.poy_output.tar.gz",  :data => poy_output).save

      if(!job.supplied_tree)
        tree_data = PoyService.get_file(job.service_id,"#{job.name}.tre")
        JobFile.new(:job_id => job.id, :file_type=>"tre",:name => "#{job.name}.tre",  :data => tree_data).save
      end

       if(!job.prealigned_fasta)
         ia_data = PoyService.get_file(job.service_id,"#{job.name}.ia")
        JobFile.new(:job_id => job.id, :file_type=>"ia",:name => "#{job.name}.ia",  :data => ia_data).save
       end

      job.status = "Downloaded Poy Files"
      job.save
    rescue Exception => ex
      job.status = "poy failed"
      job.error_output = ex.message+ex.backtrace.to_s
      job.save
      exit
    end

    job.save


  end

  def self.run_all(job )
       job.service_id = PoyService.init
    job.status = "starting poy service"
    job.save


      @poy_script =""
      fasta = JobFile.where("file_type = 'fas' and job_id=#{job.id}")[0]
      PoyService.add_text_file(job.service_id,fasta.name,fasta.data)
      #PoyService.add_file(job.service_id,fasta.name,fasta.data)
      if(job.prealigned_fasta)
        fasta[:file_type]="ia"
        fasta.save
        @poy_script <<"read(prealigned:(\"#{fasta.name}\",tcm:(1,2)))\n"
        @poy_script <<"set (root:\"#{job.outgroup}\")\n"
     else
        @poy_script <<"read (\"#{fasta.name}\")\n"
        @poy_script <<"set (root:\"#{job.outgroup}\")\n"
        @poy_script <<"transform (tcm:(1, 2))\n"
      end


      if(job.supplied_tree)
        tree= JobFile.where("file_type = 'tre' and job_id=#{job.id}")[0]
        PoyService.add_text_file(job.service_id,tree.name,tree.data)
        tree_name =    tree.name
        @poy_script << "read(\"#{tree.name}\")\n"
        @poy_script << "transform(static_approx)\n"
      else
        tree_name = "#{job.name}.tre"
        @poy_script << "search(max_time:00:0:5, memory:gb:2)\n"
        @poy_script << "transform(static_approx)\n"
        @poy_script << "select(best:1)\n"
        @poy_script << "report (\"#{job.name}.tre\", trees)\n"
      end

      if(!job.prealigned_fasta)
         @poy_script << "report (\"#{job.name}.ia\", ia)\n"
      end

      @poy_script << "report(\"#{job.name}.poy_output\",data,diagnosis)\n"
      @poy_script << "exit()\n"
      @poy_file = JobFile.new(:job_id =>job.id, :file_type=>"poy",:name => job.name+".poy",  :data => @poy_script)
      @poy_file.save
      PoyService.add_text_file(job.service_id,@poy_file.name,@poy_file.data)

       job.status = "uploaded all poy files"
       job.save

       begin
         PoyService.submit_poy(job.service_id)
         #PoyService.submit_phenGen(job.service_id,job.name,  tree_name)
      rescue Exception => ex
      job.status = "poy failed"
      job.error_output = ex.message+ex.backtrace.to_s
      job.save
      exit
    end
      job.save
  end
end
