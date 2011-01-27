class Isolate < ActiveRecord::Base
   belongs_to  :locations
   belongs_to  :pathogens
   belongs_to :hosts
  has_many    :sequences
end
