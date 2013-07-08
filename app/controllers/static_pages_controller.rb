require 'discuss_it_api_fetch'

class StaticPagesController < ApplicationController
  def index
  end

  def submit
    @d = DiscussItApiFetch.new(params[:q])
    @results = @d.find_all
  end

end
