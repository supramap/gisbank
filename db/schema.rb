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

ActiveRecord::Schema.define(:version => 20090721025943) do

  create_table "isolates", :force => true do |t|
    t.string   "tax_id",                    :limit => 50
    t.string   "isolate_id",                :limit => 50
    t.string   "sequence_ids",              :limit => 255
    t.string   "name",                      :limit => 50
    t.string   "virus_type",                :limit => 50
    t.string   "passage",                   :limit => 50
    t.datetime "collect_date"
    t.string   "host",                      :limit => 50
    t.string   "location",                  :limit => 255
    t.string   "notes",                     :limit => 50
    t.datetime "update_date"
    t.string   "is_public",                 :limit => 50
    t.string   "isolate_submitter",         :limit => 255
    t.string   "sample_lab",                :limit => 50
    t.string   "sequence_lab",              :limit => 255
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
    t.string   "antigen_character",         :limit => 255
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
    t.datetime "created_at"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "projects", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "queries", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "description"
    t.string   "isolate_name"
    t.string   "virus_type"
    t.string   "host"
    t.string   "location"
    t.datetime "max_collect_date"
    t.datetime "min_collect_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ha"
    t.boolean  "na"
    t.boolean  "pb1"
    t.boolean  "pb2"
    t.boolean  "pa"
    t.boolean  "np"
    t.boolean  "m"
    t.boolean  "ns"
  end

  create_table "sequences", :force => true do |t|
    t.string   "genbank_acc_id",  :limit => 50
    t.string   "sequence_id",     :limit => 50
    t.string   "isolate_id",      :limit => 50
    t.text     "data"
    t.datetime "created_at"
    t.string   "sequence_type", :limit => 10
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string    :login,               :null => false                # optional, you can use email instead, or both
    t.string    :email,               :null => false                # optional, you can use login instead, or both
    t.string    :crypted_password,    :null => false                # optional, see below
    t.string    :password_salt,       :null => false                # optional, but highly recommended
    t.string    :persistence_token,   :null => false                # required
    t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
    t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability

    # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
    t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
    t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
    t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
    t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
    t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
    t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
    t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns
  end

end
