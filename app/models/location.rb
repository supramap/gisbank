# To change this template, choose Tools | Templates
# and open the template in the editor.
class Location < ActiveRecord::Base
  has_many    :isolates
end

