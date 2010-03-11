#!/usr/bin/ruby

require 'rubygems'
require 'datamapper'

DataMapper.setup(:default, {
    :adapter  => 'mysql',
    :database => 'gisbank',
    :username => 'gisbank',
    :password => 'gisbank',
    :host     => 'localhost'
})

DataMapper::Logger.new(STDOUT, :debug)

class Isolate
  include DataMapper::Resource
  
  property :id, Serial, :unique_index => true
  property :tax_id, String
  property :isolate_id, String
  property :sequence_ids, Text
  property :name, Text
  property :virus_type, String
  property :passage, String
  property :collect_date, String
  property :host, String
  property :location, String, :length => 255
  property :notes, String
  property :update_date, DateTime
  property :is_public, String
  property :isolate_submitter, String, :length => 255
  property :sample_lab, String
  property :sequence_lab, String, :length => 255
  property :iv_animal_vaccin_product, String
  property :resist_to_adamantanes, String
  property :resist_to_oseltamivir, String
  property :resist_to_zanamivir, String
  property :resist_to_peramivir, String
  property :resist_to_other, String
  property :iv_sample_id, String
  property :date_selected_for_vaccine, String
  property :antigen_character, String, :length => 255
  property :pathogen_test_info, String
  property :authors, Text
  property :is_vaccinated, String
  property :human_specimen_source, String
  property :animal_specimen_source, String
  property :animal_health_status, String
  property :animal_domestic_status, String
  property :host_age, Integer
  property :host_gender, String
  property :zip_code, String
  property :patient_status, String
  property :outbreak, String
  property :latitude, BigDecimal
  property :longitude, BigDecimal
  property :created_at, DateTime
  property :collect_date_2, DateTime
  
  has n, :sequences
end

#add_index "isolates", ["isolate_id", "tax_id"], :name => "unique_isos", :unique => true

class Sequence
  include DataMapper::Resource
  
  property :id, Serial
  property :genbank_acc_id, String, :unique_index => true
  property :sequence_id, String, :unique_index => true
  property :isolate_id, String, :unique_index => :u2
  property :data, Text
  property :created_at, DateTime
  property :sequence_type, String, :unique_index => :u2
  belongs_to :isolate

end

#
# These tables are used for geo references
#

class Geo_City
  include DataMapper::Resource
  
  storage_names[:default]='geo_city'
  
  property :ip_start, Integer
  property :country_code, String
  property :country_name, String
  property :region_code, Integer
  property :region_name, String
  property :city, String
  property :zipcode, Integer
  property :latitude, BigDecimal
  property :longitude, BigDecimal
  property :gmtoffset, BigDecimal
  property :dstoffset, BigDecimal
  
end

#Isolate.auto_migrate!
#Sequence.auto_migrate!