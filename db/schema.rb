# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "hosts", :force => true do |t|
    t.string "name", :limit => 50, :null => false
  end

  create_table "isolates", :force => true do |t|
    t.string   "isolates_genBank_id", :limit => 100
    t.datetime "date"
    t.string   "virus_name",          :limit => 100
    t.integer  "location_id"
    t.integer  "pathogen_id"
    t.integer  "host_id"
  end

  create_table "isolates_genBank", :force => true do |t|
    t.string   "genBank_id",   :limit => 100, :null => false
    t.string   "host",         :limit => 30,  :null => false
    t.string   "subtype",      :limit => 4,   :null => false
    t.string   "country",      :limit => 30,  :null => false
    t.datetime "date",                        :null => false
    t.string   "virus_name",   :limit => 100, :null => false
    t.string   "mutation",     :limit => 30,  :null => false
    t.string   "age",          :limit => 10,  :null => false
    t.string   "gender",       :limit => 10,  :null => false
    t.integer  "location_id"
    t.string   "genBank_name", :limit => 50,  :null => false
    t.integer  "pathogen_id"
    t.integer  "host_id"
  end

  create_table "isolates_gisaid", :force => true do |t|
    t.string   "gisaid_id",   :limit => 100, :null => false
    t.string   "host",        :limit => 30,  :null => false
    t.string   "subtype",     :limit => 4,   :null => false
    t.string   "location",    :limit => 30,  :null => false
    t.datetime "date",                       :null => false
    t.string   "virus_name",  :limit => 100, :null => false
    t.string   "mutation",    :limit => 30,  :null => false
    t.string   "age",         :limit => 10,  :null => false
    t.string   "gender",      :limit => 10,  :null => false
    t.integer  "location_id"
    t.string   "ncbi_name",   :limit => 50,  :null => false
    t.integer  "pathogen_id"
    t.integer  "host_id"
  end

  create_table "isolates_old", :force => true do |t|
    t.string   "tax_id",                    :limit => 50
    t.string   "isolate_id",                :limit => 50
    t.string   "sequence_ids"
    t.string   "name",                      :limit => 50
    t.string   "virus_type",                :limit => 50
    t.string   "passage",                   :limit => 50
    t.string   "collect_date",              :limit => 50
    t.string   "host",                      :limit => 50
    t.string   "location"
    t.string   "notes",                     :limit => 50
    t.datetime "update_date"
    t.string   "is_public",                 :limit => 50
    t.string   "isolate_submitter"
    t.string   "sample_lab",                :limit => 50
    t.string   "sequence_lab"
    t.string   "iv_animal_vaccin_product",  :limit => 50
    t.string   "resist_to_adamantanes",     :limit => 50
    t.string   "resist_to_oseltamivir",     :limit => 50
    t.string   "resist_to_zanamivir",       :limit => 50
    t.string   "resist_to_peramivir",       :limit => 50
    t.string   "resist_to_other",           :limit => 50
    t.string   "h1n1_swine_set",            :limit => 50
    t.string   "lab_culture",               :limit => 50
    t.string   "is_complete",               :limit => 50
    t.string   "iv_sample_id",              :limit => 50
    t.string   "date_selected_for_vaccine", :limit => 50
    t.string   "provider_sample_id",        :limit => 50
    t.string   "antigen_character"
    t.string   "pathogen_test_info",        :limit => 50
    t.string   "antiviral_resistance",      :limit => 50
    t.string   "authors",                   :limit => 50
    t.string   "is_vaccinated",             :limit => 50
    t.string   "human_specimen_source",     :limit => 50
    t.string   "animal_specimen_source",    :limit => 50
    t.string   "animal_health_status",      :limit => 50
    t.string   "animal_domestic_status",    :limit => 50
    t.string   "source_name",               :limit => 50
    t.string   "geoplace_name",             :limit => 50
    t.integer  "host_age"
    t.string   "host_gender",               :limit => 50
    t.string   "zip_code",                  :limit => 50
    t.string   "patient_status",            :limit => 50
    t.string   "antiviral_treatment",       :limit => 50
    t.string   "outbreak",                  :limit => 50
    t.datetime "vaccination_last_year"
    t.text     "pathogenicity"
    t.text     "computed_antiviral"
    t.integer  "latitude",                  :limit => 10, :precision => 10, :scale => 0
    t.integer  "longitude",                 :limit => 10, :precision => 10, :scale => 0
    t.datetime "created_at"
    t.string   "pathogen",                  :limit => 20
  end

  add_index "isolates_old", ["host"], :name => "host"
  add_index "isolates_old", ["id"], :name => "id"
  add_index "isolates_old", ["isolate_id"], :name => "isolate_id"
  add_index "isolates_old", ["location"], :name => "location"
  add_index "isolates_old", ["name", "host", "location"], :name => "name_host_location"
  add_index "isolates_old", ["name"], :name => "name"
  add_index "isolates_old", ["tax_id", "isolate_id", "name"], :name => "tax_id_iso_id_name"
  add_index "isolates_old", ["tax_id", "isolate_id"], :name => "tax_iso"
  add_index "isolates_old", ["tax_id", "isolate_id"], :name => "unique_isolates_u1", :unique => true
  add_index "isolates_old", ["tax_id"], :name => "tax_id"

  create_table "locations", :force => true do |t|
    t.string "country",        :limit => 30,  :null => false
    t.string "gen_bank_label", :limit => 30,  :null => false
    t.float  "latitude"
    t.float  "longitude"
    t.string "name",           :limit => 100
    t.string "local",          :limit => 30
    t.string "continent",      :limit => 30,  :null => false
  end

  create_table "pathogens", :force => true do |t|
    t.string "name", :limit => 4, :null => false
  end

  create_table "poy_jobs", :force => true do |t|
    t.integer  "query_id"
    t.integer  "status",                            :default => 0, :null => false
    t.text     "kml",           :limit => 16777215
    t.text     "aligned_fasta", :limit => 16777215
    t.text     "output",        :limit => 16777215
    t.text     "fasta",         :limit => 16777215
    t.text     "geo",           :limit => 16777215
    t.text     "poy",           :limit => 16777215
    t.integer  "outgroup"
    t.integer  "search_time"
    t.integer  "service_job"
    t.text     "tree",          :limit => 16777215
    t.text     "poy_output",    :limit => 16777215
    t.datetime "created_at"
  end

  create_table "proteins", :force => true do |t|
    t.string "name", :limit => 10, :null => false
  end

  create_table "queries", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.string   "pathogens"
    t.string   "hosts",            :limit => 1000
    t.string   "locations",        :limit => 5000
    t.string   "proteins"
    t.datetime "max_collect_date"
    t.datetime "min_collect_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_id",                           :default => 0
    t.integer  "kml_status",                       :default => 0
    t.integer  "total_sequences",                  :default => 0
    t.boolean  "is_public",                        :default => false
    t.text     "sql"
  end

  create_table "sequences", :force => true do |t|
    t.integer "isolate_id"
    t.integer "protein_id"
    t.string  "accession",  :limit => 30
    t.string  "data",       :limit => 10000, :null => false
  end

  create_table "sequences_genBank", :force => true do |t|
    t.integer "isolates_genBank_id"
    t.string  "name",                :limit => 30,    :null => false
    t.string  "protein",             :limit => 5,     :null => false
    t.string  "data",                :limit => 10000, :null => false
    t.string  "accession",           :limit => 30
    t.integer "protein_id"
  end

  create_table "sequences_gisaid", :force => true do |t|
    t.integer "Isolates_gisaid_id"
    t.string  "name",               :limit => 30,    :null => false
    t.string  "protein",            :limit => 5,     :null => false
    t.string  "data",               :limit => 10000, :null => false
    t.string  "accession",          :limit => 30
    t.integer "protein_id"
  end

  create_table "sequences_old", :force => true do |t|
    t.string   "genbank_acc_id", :limit => 50
    t.string   "sequence_id",    :limit => 50
    t.string   "isolate_id",     :limit => 50
    t.text     "data"
    t.datetime "created_at"
    t.string   "sequence_type",  :limit => 50
  end

 # add_index "sequences_old", ["genbank_acc_id"], :name => "genbank_acc_id"
 # add_index "sequences_old", ["genbank_acc_id"], :name => "unique_sequences_genbank_acc_id", :unique => true
 # add_index "sequences_old", ["isolate_id", "sequence_type"], :name => "isolate_id"
 # add_index "sequences_old", ["isolate_id", "sequence_type"], :name => "unique_sequences_u2", :unique => true
 # add_index "sequences_old", ["sequence_id"], :name => "sequence_id"
 # add_index "sequences_old", ["sequence_id"], :name => "unique_sequences_sequence_id", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                       :null => false
    t.text     "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "login",                              :null => false
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
  end

end
