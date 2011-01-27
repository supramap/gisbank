class Sequence < ActiveRecord::Base
  belongs_to  :isolate

  def name
    return "#{subtype} : #{protein} : #{host} : #{location_name} : #{date}"
  end

end
