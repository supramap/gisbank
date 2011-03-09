class CreateJobFiles < ActiveRecord::Migration
  def self.up
    create_table :job_files do |t|
      t.integer :job_id
      t.string :name,:file_type
      t.text :data
      t.timestamps
    end
  end

  def self.down
    drop_table :job_files
  end
end
