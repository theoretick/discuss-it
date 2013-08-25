
class StaticPagesController < ApplicationController
  def index
  end

  def about
  end

  def submit
    begin
      @query_url = params[:url]

      # checks for specific version number, 2 skips slashdot
      @api_version = 2 if params[:version] == '2'

      @discuss_it = DiscussIt::DiscussItApi.new(@query_url, @api_version)

      @all_results = @discuss_it.find_all
      @top_results = @discuss_it.find_top

      @hits = set_total_results

      # provides nicely-formatted JSON return with hit count as first val
      respond_to do |format|
        format.html
        format.json {
          render :json => {
            :hits => @hits,
            :top_results => @top_results,
            :all_results => @all_results
          }
        }
      end

    rescue DiscussIt::UrlError => e
      redirect_to :root, :flash => { :error => 'Invalid URL' }
    end
  end

  def after_sign_in_path_for(user)
    index_path
  end


  private

  # returns the total number of hits for top + all results
  def set_total_results
    return @all_results.all.length + @top_results.length
  end

end
