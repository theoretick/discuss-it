
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
    # checks for specific version number, < 3 skips slashdot
    @api_version = 2 if params[:version] == '2'
    results = {}

    #caching discussit API calls
    discuss_it = DiscussIt::DiscussItApi.cached_request(@query_url, @api_version)

    @top_results ||= discuss_it.find_top
    @all_results ||= discuss_it.find_all.all

    results = {
         total_hits: total_hits_count,
        top_results: {
                 hits: top_hits_count,
              results: @top_results
          },
        all_results: {
                 hits: all_hits_count,
              results: @all_results
        }
      }

    render json: results
  end

  # new ajax-ified submit with Oboe.js
  def newsubmit
    @query_url = params[:url]
    # checks for specific version number, 2 skips slashdot
    @api_version = 2 if params[:version] == '2'
  end

  def submit
    begin

      @query_url = params[:url]
      # checks for specific version number, 2 skips slashdot
      @api_version = 2 if params[:version] == '2'

      #caching discussit API calls
      discuss_it = DiscussIt::DiscussItApi.cached_request(@query_url, @api_version)

      # result_type = params[:result_type]

      @top_results = discuss_it.find_top
      @all_results = discuss_it.find_all.all

      results = {
           total_hits: total_hits_count,
          top_results: {
                   hits: top_hits_count,
                results: @top_results
            },
          all_results: {
                   hits: all_hits_count,
                results: @all_results
          }
        }

      # provides nicely-formatted JSON return with hit count as first val
      respond_to do |format|
        format.html
        format.json {
          render json: results
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

end
