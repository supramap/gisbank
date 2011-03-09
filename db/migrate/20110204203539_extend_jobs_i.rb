class ExtendJobsI < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
  end

  def self.down
    
  end
end
