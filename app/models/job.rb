class Job < ActiveRecord::Base
  belongs_to :user
  has_many :input_file

  def uploaded_file=(file_field)


  end

end
