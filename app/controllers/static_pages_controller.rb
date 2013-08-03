
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

      @discussit = DiscussItApi.new(@query_text, @api_version)

      @all_results = @discussit.find_all
      @top_results = @discussit.find_top
    rescue DiscussItUrlError => e
      redirect_to :root, :flash => { :error => 'Invalid URL' }
    # rescue DiscussItUnknownError => e
    #   redirect_to :root, :flash => {
    #     :error => 'Error: Uh-Oh, something went very wrong, please try
    #      again later' }
    end
  end

end
