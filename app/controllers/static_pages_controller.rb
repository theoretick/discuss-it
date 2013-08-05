
class StaticPagesController < ApplicationController
  def index
  end

  def submit
    begin
      @submit_params = submit_params
      @query_text = @submit_params[:query]
      @api_version = '2'

      # Defaults to APIv2. 'beta' version uses latest (slashdot)
      if (params[:commit] == '(Beta) Search') || (@submit_params[:version] == '3')
        @api_version = '3'
      end

      @discussit = DiscussItApi.new(@query_text, @api_version)

      @all_results = @discussit.find_all
      @top_results = @discussit.find_top
    rescue DiscussItUrlError => e
      redirect_to :root, :flash => { :error => 'Invalid URL' }
    end
  end

  private

  # TODO: probably want to disable this once API is more fleshed out
  # strong params to prevent empty API calls
  def submit_params
    params.require(:url).permit(:version)
  end

end
