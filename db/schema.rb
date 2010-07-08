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

ActiveRecord::Schema.define(:version => 20100708173841) do

  create_table "isolates", :force => true do |t|
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
  end

  add_index "isolates", ["collect_date"], :name => "index_isolates_on_collect_date"
  add_index "isolates", ["h1n1_swine_set"], :name => "index_isolates_on_h1n1_swine_set"
  add_index "isolates", ["host"], :name => "index_isolates_on_host"
  add_index "isolates", ["location"], :name => "index_isolates_on_location"
  add_index "isolates", ["virus_type"], :name => "index_isolates_on_virus_type"

  create_table "queries", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "isolate_name"
    t.string   "virus_type"
    t.string   "h1n1_swine_set"
    t.string   "hosts"
    t.string   "locations"
    t.datetime "max_collect_date"
    t.datetime "min_collect_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "proteins"
    t.integer  "user_id"
  end

  create_table "sequences", :force => true do |t|
    t.string   "genbank_acc_id", :limit => 50
    t.string   "sequence_id",    :limit => 50
    t.string   "isolate_id",     :limit => 50
    t.text     "data"
    t.datetime "created_at"
    t.string   "sequence_type",  :limit => 50
  end

  add_index "sequences", ["isolate_id"], :name => "index_sequences_on_isolate_id"
  add_index "sequences", ["sequence_type"], :name => "index_sequences_on_sequence_type"

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
