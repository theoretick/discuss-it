require 'discuss_it_api'

class StaticPagesController < ApplicationController
  def index
  end

  def submit
    begin
      @discussit = DiscussItApi.new(params[:q])
      @results = @discussit.find_all
    rescue DiscussItUrlError => e
      redirect_to index_path, :error => 'Invalid URL'
    end
  end

end
