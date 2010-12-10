class SqlQuery < ActiveRecord::Base
  #@hosts
  #@pathegens
  #@locations
  def self.create user_id, params
      @sql_query = SqlQuery.new
      @sql_query.users_id =user_id
      @sql_query.query_string= "SELECT * FROM gisbank.isolates where 1=1"

    return @sql_query
  end

  def self.form_values
    form_hash = {}

    form_hash[:types] = ['-ALL-', 'A / H1N1', 'A / H5N1']

    #form_hash[:lineages] = {'-ALL-'=>'-ALL-', 'Pandemic'=>'Y', 'Seasonal'=>'N'}
    form_hash[:lineages] = {'-ALL-'=>'-ALL-', 'Pandemic'=>'Pandemic', 'Seasonal'=>'Seasonal'}
    arr = []
    Isolate.find(:all, :select  => 'Distinct pathogen').each do |iso|
       arr << iso[:pathogen]
    end
    form_hash[:pathogen] = arr


    arr = ['-ALL-']
	Isolate.find(:all, :select => 'Distinct host', :order => "host").each do |iso|
	    arr << iso[:host] unless iso[:host].blank?
	end
	form_hash[:hosts] = arr

    arr = ['-ALL-']
	Isolate.find(:all, :select => 'Distinct location', :order => "location").each do |iso|
	  arr << iso[:location] unless iso[:location].blank?
	end
	form_hash[:locations] = arr

    form_hash[:proteins] = ['-ALL-','HA', 'NA', 'PB1', 'PB2', 'PA', 'NP', 'MP', 'NS']

    return form_hash
  end


  def get_sequences
    return find_by_sql(query_string)

  end

end
