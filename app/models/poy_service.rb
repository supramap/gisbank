# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'savon'


require 'rubygems'
require 'httparty'

class Poy_service
  include HTTParty
  #base_uri 'http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx'
  base_uri 'http://poyws.osc.edu/PoyService.asmx'
  default_params

  def initialize()

  end

#  def self.init(resource)
#    log "/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT&resource=#{resource}"
#    get("/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT&resource=#{resource}")["int"]
#  end

  def self.init()
    log "/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT&resource=oakley"
    get("/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT&resource=oakley")["int"]
  end

  def self.add_text_file(job_id,file_name,file_data)
    log "?? anding file jobId=#{job_id}&fileData=#{file_data}&fileName=#{file_name}"
    post("/AddTextFile",{:body => "jobId=#{job_id}&fileData=#{file_data}&fileName=#{file_name}"})

  end

  def self.submit_poy(job_id,minutes,nodes)
     @hours = minutes.div(60);
     @minutes = minutes.modulo(60);
     log "/SubmitPoy?jobId=#{job_id}&numberOfNodes=#{nodes}&wallTimeHours=#{@hours}&wallTimeMinutes=#{@minutes}&postBackURL=gisbank.bmi.ohio-state.edu/poy/done/#{job_id}"
     get("/SubmitPoy?jobId=#{job_id}&numberOfNodes=#{nodes}&wallTimeHours=#{@hours}&wallTimeMinutes=#{@minutes}&postBackURL=gisbank.bmi.ohio-state.edu/poy/done/#{job_id}")["string"]
  end

  def self.is_done_yet(job_id)
    log "/IsDoneYet?jobId=#{job_id}&command=poy"
    results = get("/IsDoneYet?jobId=#{job_id}&command=poy");
    return ((results["q1:boolean"] == 'true' )||(  results["boolean"] == 'true'))

  end

  def self.get_file(job_id,file_name)
    log "/GetTextFile?jobId=#{job_id}&fileName=#{file_name}"
    results = get "/GetTextFile?jobId=#{job_id}&fileName=#{file_name}"
    return results['string']

  end
  def self.delete(job_id)
    log "/PoyService.asmx/DeleteJob?jobId=#{job_id}"
    get("/PoyService.asmx/DeleteJob?jobId=#{job_id}")
  end

  def self.log(string)
    file = File.new('log/service_calls.txt', "a")
    file.write  base_uri+string+"\n\n"
    file.flush; file.close
  end
end
