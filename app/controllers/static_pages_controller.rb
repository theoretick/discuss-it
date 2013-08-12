
class StaticPagesController < ApplicationController
  def index
  end

  def submit
    begin
      @query_text = params[:query]
      @api_version = '2'

      # Defaults to APIv2. 'beta' version uses latest (slashdot)
      if (params[:commit] == '(Beta) Search') || (params[:version] == '3')
        @api_version = '3'
      end

      @discussit = DiscussIt::DiscussItApi.new(@query_text, @api_version)

      @all_results = @discussit.find_all
      @top_results = @discussit.find_top
    rescue DiscussIt::UrlError => e
      redirect_to :root, :flash => { :error => 'Invalid URL' }
    end
  end

end
