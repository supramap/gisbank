class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :user_id, :pid, :service_id
      t.string :status, :name, :outgroup
      t.text :standard_output,  :error_output
      t.boolean :supplied_tree,:prealigned_fasta

      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
