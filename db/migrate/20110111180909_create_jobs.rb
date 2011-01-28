class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :user_id, :pid
      t.string :status, :name
      t.text :standard_output,  :error_output
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
