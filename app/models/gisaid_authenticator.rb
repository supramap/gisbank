require 'net/http'
require 'rexml/document'

# *not* an ActiveRecord model...
class GISAIDAuthenticator
  
  def initialize(sid)
    @uri = URI.parse("#{GISAID_URL}#{sid}")
    @params = {}
  end
  
  # returns the xml response from platform.gisaid.org
  def authenticate
    @xml = NET:HTTP.get_response(@uri).body
    parse_xml(@xml)
    self
  end
  
  # allows method calls on params
  def method_missing(name, *args)
    return params[name]
  end
  
  def get_flash_notice
    return "Username or password incorrect." if params["rc"] == "SID UNKNOWN"
    return "The service is unavailable." if params["rc"] == "SERVICE UNAVAILABLE"
  end
  
  def build_user_from_xml_response
    User.new(:gisaid_user_id => params["user_id"], :login_name => params["login"], :email => params["email"], :organization => params["organization"], :last_name => params["last_name"], :first_name => params["first_name"])
  end
  
  private 
      
  def parse_xml(xml)
    root = REXML::Document(xml).root
    params["rc"] = root.elements["rc"].text
    params["user_id"] = root.elements["dauser.usr_id"].text
    params["login"] = root.elements["dauser.usr_login"].text
    params["last_name"] = root.elements["dauser.usr_name"].text
    params["first_name"] = root.elements["dauser.usr_vorname"].text
    params["email"] = root.elements["dauser.usr_email"].text
    params["organization"] = root.elements["dauser.usr_organisation"].text
  end
  

end