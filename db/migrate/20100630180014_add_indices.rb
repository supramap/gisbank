class AddIndices < ActiveRecord::Migration
  def self.up
	add_index :sequences, :isolate_id
	add_index :sequences, :sequence_type

	add_index :isolates, :collect_date
	add_index :isolates, :virus_type
	add_index :isolates, :host
	add_index :isolates, :location
	add_index :isolates, :h1n1_swine_set
  end

  def self.down
	remove_index :sequences, :isolate_id
	remove_index :sequences, :sequence_type

	remove_index :isolates, :collect_date
	remove_index :isolates, :virus_type
	remove_index :isolates, :host
	remove_index :isolates, :location
	remove_index :isolates, :h1n1_swine_set
  end
end
