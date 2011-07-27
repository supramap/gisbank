# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'savon'


require 'rubygems'
require 'httparty'

#require 'base64'

#require 'net/http'
#require 'uri'

#require 'soap/wsdlDriver'
#require 'cgi'

class Poy_service
  include HTTParty
  base_uri 'http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx'
  #base_uri 'http://140.254.80.123//PoyService.asmx'
  default_params

  def initialize()

  end

  def self.init(resource)
    log "/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT&resource=#{resource}"
    get("/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT&resource=#{resource}")["int"]
    #get("/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT&resource=glenn")["int"]
    #get("/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT")["int"]
  end

#  def self.add_poy_file(job_id,job_name,minutes)
#
#      @hours = minutes.div(60);
#      @minutes = minutes.modulo(60);
#
#     file_data = "read (\"#{job_name.gsub(" ","")}.fasta\")
#                search(max_time:00:#{@hours}:#{@minutes}, memory:gb:2)
#                select(best:1)
#                transform (static_approx)
#                report (\"results.kml\", kml:(supramap, \"#{job_name.gsub(" ","")}.csv\"))
#                report (\"A2alignment.fas\", ia)
#                exit ()
#    #"
#
#
#    add_text_file(job_id,"run.poy", file_data)
#
#  end

  def self.add_text_file(job_id,file_name,file_data)
    #soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
    #opt2 = soap.AddFile(:jobId => job_id,:fileData => file_data,:fileName => file_name.gsub(" ",""))
    log "?? anding file jobId=#{job_id}&fileData=#{file_data}&fileName=#{file_name}"
    post("/AddTextFile",{:body => "jobId=#{job_id}&fileData=#{file_data}&fileName=#{file_name}"})

  end

  #def self.add_file(job_id,file_name,file_data)
  #  encoded_file_data = Base64.encode64(file_data)
  #  soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
  #  opt2 = soap.AddFile(:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name.gsub(" ",""))
  #end
  
  def self.submit_poy(job_id,minutes,nodes)

     @hours = minutes.div(60);
     @minutes = minutes.modulo(60);
   log "/SubmitPoy?jobId=#{job_id}&numberOfNodes=#{nodes}&wallTimeHours=#{@hours}&wallTimeMinutes=#{@minutes}&postBackURL=gisbank.bmi.ohio-state.edu/poy/done/#{job_id}"
   get("/SubmitPoy?jobId=#{job_id}&numberOfNodes=#{nodes}&wallTimeHours=#{@hours}&wallTimeMinutes=#{@minutes}&postBackURL=gisbank.bmi.ohio-state.edu/poy/done/#{job_id}")["string"]
    #get("/SubmitSmallPoy?jobId=#{job_id}")["boolean"]
  end

  def self.is_done_yet(job_id)
    log "/IsDoneYet?jobId=#{job_id}&command=poy"
    results = get("/IsDoneYet?jobId=#{job_id}&command=poy");

    return ((results["q1:boolean"] == 'true' )||(  results["boolean"] == 'true'))

  end

  def self.get_file(job_id,file_name)
    #s5 = "http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx/GetTextFile?jobId=#{job_id}&fileName=#{file_name}"
    log "/GetTextFile?jobId=#{job_id}&fileName=#{file_name}"
    results = get "/GetTextFile?jobId=#{job_id}&fileName=#{file_name}"
    return results['string']
    #soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
    #file =  soap.GetFile(:jobId => job_id,:fileName => file_name)
    #file2 =  soap.GetTextFile(:jobId => job_id,:fileName => file_name)
    #return Base64.decode64 file

    #client = Savon::Client.new do
    #  wsdl.document = "http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl"
    #end
    #actions = client.wsdl.soap_actions
    #response = client.request :GetTextFile do
    #  soap.body = { :jobId => job_id,:fileName => file_name }
    #end

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
