require 'discuss_it_api'

class StaticPagesController < ApplicationController
  def index
  end

  def submit
    @discussit = DiscussItApi.new(params[:q])
    @results = @discussit.find_all
  end

end
