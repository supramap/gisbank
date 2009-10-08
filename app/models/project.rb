class Project < ActiveRecord::Base
  has_many    :queries
  belongs_to  :user
  validates_presence_of :user_id, :name
end
