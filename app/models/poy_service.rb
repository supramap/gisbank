# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'httparty'
require 'base64'

require 'net/http'
require 'uri'

require 'soap/wsdlDriver'
require 'cgi'

class Poy_service
  include HTTParty
  base_uri 'http://glenn-webservice.bmi.ohio-state.edu//PoyService.asmx'
  default_params

  def initialize()

  end


  def self.init

    get("/Init?passPhase=JDWKWHDFMCMAHHMCJVHVPJDIRJNGNTINIMQRBPNUSGBYLYESGT")["int"]
  end

  def self.add_poy_file(job_id,job_name,minutes)


      @hours = minutes.div(60);
      @minutes = minutes.modulo(60);
#     file_data = "read (\"#{job_name}.fasta\") \n"+
#             "build (100) transform (static_approx) \n"+
#             "report (\"results.kml\", kml:(supramap, \"#{job_name}.csv\"))  \n"+
#             "exit () \n";

     file_data = "read (\"#{job_name}.fasta\")
                search(max_time:00:#{@hours}:#{@minutes}, memory:gb:8)
                select(best:1)
                transform (static_approx)
                report (\"results.kml\", kml:(supramap, \"#{job_name}.csv\"))
                report (\"A2alignment.fas\", ia)
                exit ()"


    add_text_file(job_id,"run.poy", file_data)

  end

  def self.add_text_file(job_id,file_name,file_data)
    soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
    opt2 = soap.AddFile(:jobId => job_id,:fileData => file_data,:fileName => file_name)
  end

  def self.add_file(job_id,file_name,file_data)

    encoded_file_data = Base64.encode64(file_data)

    soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
    #opt = soap.AddTextFile(:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name)
    opt2 = soap.AddFile(:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name)

  end
  
  def self.submit_poy(job_id,minutes)

     @hours = minutes.div(60);
      @minutes = minutes.modulo(60);

   get("/SubmitPoy?jobId=#{job_id}&numberOfNodes=100&wallTimeHours=#{@hours}&wallTimeMinutes=#{@minutes}")["boolean"]
    #get("/SubmitSmallPoy?jobId=#{job_id}")["boolean"]
  end

  def self.is_done_yet(job_id)
    return (get("/IsDoneYet?jobId=#{job_id}")["q1:boolean"] == 'true' )||(  get("/IsDoneYet?jobId=#{job_id}")["boolean"] == 'true')
  end

  def self.get_file(job_id,file_name)

    get("/GetTextFile?jobId=#{job_id}&fileName=#{file_name}")["string"]
    #Base64.decode64(get("/GetFile?jobId=#{job_id}&fileName=#{file_name}")["base64Binary"]);
    
   #  soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
   # opt = soap.GetFile(:jobId => job_id,:fileName => file_name)
   # return opt

  end
end