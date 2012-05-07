# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
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

  add_index "isolates", ["host_id"], :name => "host"
  add_index "isolates", ["location_id"], :name => "lococation_con"
  add_index "isolates", ["pathogen_id"], :name => "pathogen"

  create_table "locations", :force => true do |t|
    t.string "country",   :limit => 30, :null => false
    t.float  "latitude"
    t.float  "longitude"
    t.string "local",     :limit => 30
    t.string "continent", :limit => 30, :null => false
  end

  create_table "pathogens", :force => true do |t|
    t.string "name", :limit => 10, :null => false
  end

  create_table "poy_jobs", :force => true do |t|
    t.integer  "query_id"
    t.integer  "status",                              :default => 0, :null => false
    t.text     "kml",           :limit => 2147483647
    t.text     "aligned_fasta", :limit => 2147483647
    t.text     "output",        :limit => 2147483647
    t.text     "fasta",         :limit => 2147483647
    t.text     "geo",           :limit => 2147483647
    t.text     "poy",           :limit => 2147483647
    t.integer  "outgroup"
    t.integer  "search_time"
    t.integer  "service_job"
    t.text     "tree",          :limit => 2147483647
    t.text     "poy_output",    :limit => 2147483647
    t.datetime "created_at"
    t.string   "resource",      :limit => 30
  end

  add_index "poy_jobs", ["id", "query_id"], :name => "lookup"

  create_table "proteins", :force => true do |t|
    t.string "name", :limit => 10, :null => false
  end

  create_table "query2s", :force => true do |t|
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

  add_index "sequences", ["isolate_id"], :name => "isolate_key"
  add_index "sequences", ["protein_id"], :name => "protein_key"

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                       :null => false
    t.text     "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
