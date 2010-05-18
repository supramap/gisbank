class ChangeTypeToProtein < ActiveRecord::Migration
  def self.up
  	rename_column :queries, :type, :protein
  end

  def self.down
  	rename_column :queries, :protein, :type
  end
end
