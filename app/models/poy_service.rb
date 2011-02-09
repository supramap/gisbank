require 'httparty'

class PoyService
  include HTTParty
  base_uri 'http://glenn-webservice.bmi.ohio-state.edu//PoyService.asmx'
  default_params

  def initialize()

  end

  def self.init
    get("/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT")["int"]
  end

  def self.add_text_file(job_id,file_name,file_data)
    post("/AddTextFile",{:body => "jobId=#{job_id}&fileData=#{file_data}&fileName=#{file_name}"})
  end

  def self.submit_poy(job_id)
   get("/SubmitPoy?jobId=#{job_id}&numberOfNodes=2&wallTimeHours=1&wallTimeMinutes=0")["string"]
  end

  def self.is_done_yet(job_id)
    results = get("/IsDoneYet?jobId=#{job_id}");
    return ((results["q1:boolean"] == 'true' )||(  results["boolean"] == 'true'))
  end

  def self.get_file(job_id,file_name)
    results = get "/GetTextFile?jobId=#{job_id.to_s}&fileName=#{file_name}"
    return results['string']
  end
  def self.delete(job_id)
    get("/PoyService.asmx/DeleteJob?jobId=#{job_id}")
  end

end