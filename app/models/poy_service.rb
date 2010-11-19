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
  base_uri 'http://140.254.80.123/PoyService.asmx'
  default_params

  def initialize()

  end


  def self.init

    get("/Init?")["int"]
  end

  def self.add_poy_file(job_id,job_name)

#   file_data = "read (\"#{job_name}.fasta\") \n"+
#               "build (100) transform (static_approx) \n"+
#               "report (\"results.kml\", kml:(supramap, \"#{job_name}.csv\"))  \n"+
#               "exit () \n";

     file_data = "read (\"#{job_name}.fasta\") \n"+
             "build (100) transform (static_approx) \n"+
             "report (\"results.kml\", kml:(supramap, \"#{job_name}.csv\"))  \n"+
             "exit () \n";

    add_text_file(job_id,"run.poy", file_data)

  end

  def self.add_text_file(job_id,file_name,file_data)
    soap = SOAP::WSDLDriverFactory.new("http://140.254.80.123/PoyService.asmx?wsdl").create_rpc_driver()
    opt2 = soap.AddFile(:jobId => job_id,:fileData => file_data,:fileName => file_name)
  end

  def self.add_file(job_id,file_name,file_data)

    encoded_file_data = Base64.encode64(file_data)

    #get("/AddFile?jobId=#{job_id}&fileData=\"#{encoded_file_data}\"&fileName=\"#{file_name}\"")["boolean"]
    #post("/AddFile", :query => {:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name})
    #post("/AddFile", :query => {"jobId" => job_id,"fileData" => encoded_file_data,"fileName" => file_name})
   

    #Net::HTTP.post_form(URI.parse("http://140.254.80.123/PoyService.asmx/AddTextFile"),
    #  {"jobId" => job_id,"fileData" => encoded_file_data,"fileName" => file_name})

    #soap = SOAP::WSDLDriverFactory.new("http://140.254.80.123/PoyService.asmx?wsdl").create_rpc_driver()
    #soap.AddFile(:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name)

     #Net::HTTP.post_form(URI.parse("http://140.254.80.123/PoyService.asmx/AddTextFile"),
    #  {:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name})

    # Net::HTTP.post_form(URI.parse("http://140.254.80.123/PoyService.asmx/AddTextFile"),
    #  "jobId=#{job_id}&fileData=#{encoded_file_data}&fileName=#{file_name}")

    soap = SOAP::WSDLDriverFactory.new("http://140.254.80.123/PoyService.asmx?wsdl").create_rpc_driver()
    #opt = soap.AddTextFile(:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name)
    opt2 = soap.AddFile(:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name)

  end
  
  def self.submit_poy(job_id)

   get("/SubmitPoy?jobId=#{job_id}&numberOfNodes=30&wallTimeHours=2&wallTimeMinutes=0")["boolean"]
    #get("/SubmitSmallPoy?jobId=#{job_id}")["boolean"]
  end

  def self.is_done_yet(job_id)
    get("/IsDoneYet?jobId=#{job_id}")["boolean"]
  end

  def self.get_file(job_id,file_name)

   # get("/GetFile?jobId=#{job_id}&fileName=#{file_name}")["base64Binary"]
    Base64.decode64(get("/GetFile?jobId=#{job_id}&fileName=#{file_name}")["base64Binary"]);
  end
end
