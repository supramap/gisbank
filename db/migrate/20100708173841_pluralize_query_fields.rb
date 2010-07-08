class PluralizeQueryFields < ActiveRecord::Migration
  def self.up
  	rename_column :queries, :location, :locations
  	rename_column :queries, :host, :hosts
  	rename_column :queries, :protein, :proteins
  end

  def self.down
	rename_column :queries, :locations, :location
  	rename_column :queries, :hosts, :host
  	rename_column :queries, :proteins, :protein
  end
end
