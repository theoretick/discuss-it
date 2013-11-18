
class StaticPagesController < ApplicationController
  def index
  end

  def about
  end

  # developer page for api info
  def developer
  end

  # kicks off API calls for AJAX-loading on submit page
  def get_discussions
    @query_url = params[:url]

    # ALWAYS remove trailing slash before get_response calls
    @query_url.chop! if @query_url.end_with?('/')

    # checks for specific version number, < 3 skips slashdot
    @api_version = 2 if params[:version] == '2'
    results = {}

    # caching discussit API calls
    discuss_it = DiscussIt::DiscussItApi.cached_request(@query_url, @api_version)

    @top_raw ||= discuss_it.find_top
    @all_raw ||= discuss_it.find_all.all

    @top_results, filtered_top_results = DiscussIt::Filter.filter_threads(@top_raw)
    @all_results, filtered_all_results = DiscussIt::Filter.filter_threads(@all_raw)

    @filtered_results = (filtered_all_results + filtered_top_results).uniq

    results = {
         total_hits: total_hits_count,
        top_results: {
                 hits: top_hits_count,
              results: @top_results
          },
        all_results: {
                 hits: all_hits_count,
              results: @all_results
        },
        filtered_results: {
                 hits: filtered_hits_count,
              results: @filtered_results
        }
      }

    render json: results
  end

  def submit
    @query_url = params[:url]
    # checks for specific version number, 2 skips slashdot
    @api_version = 2 if params[:version] == '2'
  end

  def after_sign_in_path_for(user)
    index_path
  end


  private

  # returns the total number of hits for top + all results
  def total_hits_count
    return top_hits_count + all_hits_count
  end

  # returns the total number of hits for top results
  def top_hits_count
    return @top_results.length || 0
  end

  # returns the total number of hits for all results
  def all_hits_count
    return @all_results.length || 0
  end

  # returns the total number of hits for filtered results
  def filtered_hits_count
    return @filtered_results.length || 0
  end

end
