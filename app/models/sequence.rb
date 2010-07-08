class Sequence < ActiveRecord::Base
  belongs_to  :isolate

  def self.form_values
    form_hash = {}
    form_hash[:types] = types
    form_hash[:lineages] = lineages
    form_hash[:hosts] = hosts
    form_hash[:locations] = locations
    form_hash[:proteins] = proteins
    return form_hash
  end

  private

  def self.types
    ['-ALL-', 'A / H1N1', 'A / H5N1']
  end

  def self.lineages
    {'-ALL-'=>'-ALL-', 'Pandemic'=>'Y', 'Seasonal'=>'N'}
  end

  def self.hosts
    arr = ['-ALL-']
	Isolate.find(:all, :select => 'Distinct host', :order => "host").each do |it|
	    arr << it.host if it.host != nil
	end
	return arr
  end

  def self.locations
    arr = ['-ALL-']
	Isolate.find(:all, :select => 'Distinct location', :order => "location").each do |it|
	  arr << it.location if it.location != nil
	end
	return arr
  end

  def self.proteins
	['-ALL-','HA', 'NA', 'PB1', 'PB2', 'PA', 'NP', 'MP', 'NS']
  end
end
