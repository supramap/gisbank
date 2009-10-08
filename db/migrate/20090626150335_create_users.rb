class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :gisaid_user_id
      t.string :login_name
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :organization
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
