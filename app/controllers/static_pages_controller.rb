
class StaticPagesController < ApplicationController
  def index
  end

  def submit
    begin
      @query_text = params[:query]

      # checks for specific version number
      if (params[:commit] == '(Beta) Search') || (params[:version] == '3')
        @api_version = '3'
      elsif params[:version] == '2'
        @api_version = '2'
      end

      @discussit = DiscussIt::DiscussItApi.new(@query_text, @api_version)

      @all_results = @discussit.find_all
      @top_results = @discussit.find_top
    rescue DiscussIt::UrlError => e
      redirect_to :root, :flash => { :error => 'Invalid URL' }
    end
  end

end
