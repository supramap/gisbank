class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.integer   :project_id
      t.string    :name
      t.string    :description
      t.string    :isolate_name
      t.string    :isolate_id
      t.string    :sequence_id
      t.string    :virus_type
      t.string    :passage
      t.string    :host
      t.string    :location
      t.datetime  :max_collect_date
      t.datetime  :min_collect_date
      t.string    :fafsa
      t.string    :csv
      t.timestamps
    end
  end

  def self.down
    drop_table :queries
  end
end
