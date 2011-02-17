class PoyRunner

  def self.create_poy_script(job)
    poy_script =""
    fasta = JobFile.where("file_type = 'fas' and job_id=#{job.id}")[0]
    #PoyService.add_text_file(job.service_id, fasta.name, fasta.data)

    if (job.prealigned_fasta)
      poy_script <<"read(prealigned:(\"#{fasta.name}\",tcm:(1,2)))\n"
      poy_script <<"set (root:\"#{job.outgroup}\")\n"
    else
      poy_script <<"read (\"#{fasta.name}\")\n"
      poy_script <<"set (root:\"#{job.outgroup}\")\n"
      poy_script <<"transform (tcm:(1, 2))\n"
    end


    if (job.supplied_tree)
      tree= JobFile.where("file_type = 'tre' and job_id=#{job.id}")[0]
      #PoyService.add_text_file(job.service_id, tree.name, tree.data)

      poy_script << "read(\"#{tree.name}\")\n"
      poy_script << "transform(static_approx)\n"
    else

      poy_script << "search(max_time:00:0:5, memory:gb:2)\n"
      poy_script << "transform(static_approx)\n"
      poy_script << "select(best:1)\n"
      poy_script << "report (\"#{job.name}.tre\", trees)\n"
    end

    poy_script << "report(\"#{job.name}.poy_output\",data,diagnosis)\n"
    poy_script << "exit()\n"
    return poy_script
  end

  def self.run(job)


    job.status = "running poy locally"
    job.save

    begin

      dir="#{RAILS_ROOT}/tmp/#{job.id}_poy/"
      path_dir=  "#{RAILS_ROOT}/back_end_scripts/"

     `mkdir #{dir}`

      poy_script =create_poy_script(job)
      poy_file = JobFile.new(:job_id =>job.id, :file_type=>"poy",:name => job.name+".poy",  :data => poy_script)
      poy_file.save
      poy_file.write(dir)
    
      JobFile.where("file_type = 'fas' and job_id=#{job.id}")[0].write(dir)

      if(job.supplied_tree)
        JobFile.where("file_type = 'tre' and job_id=#{job.id}")[0].write(dir)
      end

      `echo "xterm -e  #{path_dir}ncurses_poy -w #{dir} #{dir+poy_file.name}" >#{dir}log.txt `
      `xterm -e #{path_dir}ncurses_poy -w #{dir} #{dir+poy_file.name}`

      JobFile.save_file(job.id,dir, "#{job.name}.poy_output","poy_out")


       if(!job.supplied_tree)
          JobFile.save_file(job.id,dir, "#{job.name}.tre","tre")
      end



    rescue Exception => ex
      job.status = "poy failed"
      job.error_output = ex.message+ex.backtrace.to_s
      job.save
      exit
    end

    job.save


  end
  


end