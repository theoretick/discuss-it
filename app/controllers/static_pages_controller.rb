
class StaticPagesController < ApplicationController
  def index
  end

  def about
  end

  # developer page for api info
  def developer
  end

  def submit
    begin

      @query_url = params[:url]
      # checks for specific version number, 2 skips slashdot
      @api_version = 2 if params[:version] == '2'

      #caching discussit API calls
      discuss_it = DiscussIt::DiscussItApi.cached_request

      # result_type = params[:result_type]

      @top_results = discuss_it.find_top
      top_results = {
           hits: set_top_hits,
        results: @top_results
      }

      @all_results = discuss_it.find_all.all
      all_results = {
           hits: set_all_hits,
        results: @all_results
      }

      # provides nicely-formatted JSON return with hit count as first val
      respond_to do |format|
        format.html
        format.json {
          render json: {
            # TODO: this total is nonconditional, should change w/ params
             total_hits: set_total_hits,
            top_results: top_results,
            all_results: all_results
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
  def set_total_hits
    return set_top_hits + set_all_hits
  end

  # returns the total number of hits for top results
  def set_top_hits
    return @top_results.length || 0
  end

  # returns the total number of hits for all results
  def set_all_hits
    return @all_results.length || 0
  end

end
