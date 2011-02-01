class CreateInputFiles < ActiveRecord::Migration
  def self.up
    create_table :input_files do |t|
      t.integer :job_id
      t.string :name
      t.binary :data
      t.string :type
      t.timestamps
    end
  end

  def self.down
    drop_table :input_files
  end
end
