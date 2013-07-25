require 'discuss_it_api_v3'

class StaticPagesController < ApplicationController
  def index
  end

  def submit
    begin
      @query_text = params[:query]
      @discussit = DiscussItApi.new(params[:query])
      @all_results = @discussit.find_all
      @top_results = @discussit.find_top
    rescue DiscussItUrlError => e
      redirect_to :root, :flash => { :error => 'Invalid URL' }
    end
  end

end
