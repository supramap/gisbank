require 'rubygems'
require 'base64'
require 'httparty'
require 'savon'

class PoyService
  include HTTParty
  base_uri 'http://glenn-webservice.bmi.ohio-state.edu//PoyService.asmx'
  #base_uri 'http://127.0.0.1:8080//PoyService.asmx'
  default_params

  def initialize()

  end

  def self.init
    get("/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT")["int"]
  end

  def self.add_text_file(job_id, file_name, file_data)
    post("/AddTextFile", {:body => "jobId=#{job_id}&fileData=#{file_data}&fileName=#{file_name}"})

    # client = Savon::Client.new do
    #   wsdl.document = "http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl"
    # end

    # client.request :add_text_file do
    #   soap.body = {:jobId => job_id,  :fileData => file_data, :fileName => file_name   }
    # end

  end

  def self.add_file(job_id, file_name, file_data)
    require 'rubygems'
    require 'base64'
    bin = Base64.encode64(file_data)
    post("/AddFile", {:body => "jobId=#{job_id}&fileData=#{bin}&fileName=#{file_name}"})
  end

  def self.submit_poy(job_id)
    get("/SubmitPoy?jobId=#{job_id}&numberOfNodes=2&wallTimeHours=3&wallTimeMinutes=0")["string"]
  end

  def self.is_done_yet(job_id)
    results = get("/IsDoneYet?jobId=#{job_id}");
    return ((results["q1:boolean"] == 'true')||(results["boolean"] == 'true'))
  end

  def self.get_file(job_id, file_name)
    results = get "/GetTextFile?jobId=#{job_id.to_s}&fileName=#{file_name}"
    return results['string']
  end

  def self.get_zip_file(job_id, file_name)
    require 'rubygems'
    require 'base64'

    #client = Savon::Client.new do
    #  wsdl.document = "http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl"
    #end
    #responce = client.request :get_ziped_file do
    #  soap.body = {:compressionType => 'tar.gz', :jobId => job_id.to_s, :fileName => file_name}
    #end
    #return Base64.decode64(r.to_hash['base64Binary'])

    results = get "/GetZipedFile?compressionType=tar.gz&jobId=#{job_id.to_s}&fileName=#{file_name}"
    bin =  Base64.decode64(results['base64Binary'])
    return bin
  end

  def self.delete(job_id)
    get("/PoyService.asmx/DeleteJob?jobId=#{job_id}")
  end

end