class AddProteinToQuery < ActiveRecord::Migration
  def self.up
    add_column :queries, :ha, :boolean
    add_column :queries, :na, :boolean
    add_column :queries, :pb1, :boolean
    add_column :queries, :pb2, :boolean
    add_column :queries, :pa, :boolean
    add_column :queries, :np, :boolean
    add_column :queries, :m, :boolean
    add_column :queries, :ns, :boolean
  end

  def self.down
    
  end
end
