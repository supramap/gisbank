class InputFileController < ApplicationController
  def new
    render :inline =>
  "xml.p {'Horrid coding practice!'}", :layout => false #,:type => :builder
  end

  def create
  end

  def show
  end

  def delete
  end

end
