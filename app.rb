require 'bundler'
require 'sinatra/reloader'

require './lib/discuss_it'
require './lib/subreddit_loader'

module DiscussIt
  class App < Sinatra::Base

    include DiscussIt

    configure do
      enable :logging
      set :root, File.dirname(__FILE__)
      set :views, Proc.new { File.join(root, 'app', 'views') }
      set :protection, :except => [:json_csrf]
    end

    configure :production, :development do
      log_path = "#{root}/log"
      Dir.mkdir(log_path) unless File.exist?(log_path)
      log_file = File.new("#{log_path}/#{settings.environment}.log", "a+")
      log_file.sync = true
      STDOUT.reopen(log_file)
      STDERR.reopen(log_file)
    end

    configure :development do
      register Sinatra::Reloader
      also_reload 'app/**/*.rb'
      also_reload 'lib/**/*.rb'
    end


    get '/' do
      haml :index
    end

    get '/submit' do
      @query_url = strip_params? ? params[:url].split("?").first : params[:url]
      haml :submit, locals: {query_url:  @query_url}
    end

    get '/about' do
      haml :about
    end

    get '/api' do
      haml :developers
    end

    get '/api/get_discussions?:url?' do
      content_type :json

      @query_url = params[:url]
      source = set_source

      # ALWAYS remove trailing slash before get_response calls
      @query_url.chop! if has_trailing_slash?

      if caching?
        discuss_it = Caching::Redis.fetch(@query_url, source: source)
      else
        discuss_it = DiscussItApi.new(@query_url, source: source)
      end

      top_raw ||= discuss_it.find_top
      all_raw ||= discuss_it.find_all.all
      @errors = discuss_it.errors.collect(&:message)

      @top_results, filtered_top_results = Filter.filter_threads(top_raw)
      @all_results, filtered_all_results = Filter.filter_threads(all_raw)
      @other_results = @all_results - @top_results
      @filtered_results = (filtered_all_results + filtered_top_results).uniq

      result_response.to_json
    end

    #--------------------------
    #    Subscriber loader    #
    #--------------------------

    get '/loader/subreddits' do
      if confirmed?
        runtime = perform_load_subs
        {message: "loaded n subs in #{runtime} seconds!"}.to_json
      else
        406
      end
    end

    get '/loader/flush' do
      if confirmed?
        runtime = perform_flush_db
        {message: "flushed subs in #{runtime} seconds!"}.to_json
      else
        406
      end
    end

    private

    # remove params from base url if requested (default: true)
    def strip_params?
      params[:strip_params] == 'true'
    end

    def has_trailing_slash?
      @query_url.end_with?('/')
    end

    def set_source
      params[:source] || ['all']
    end

    # build response hash one node at a time
    def result_response
      [
        total_hits_node,
        results_node(:top_results, @top_results),
        results_node(:other_results, @other_results),
        results_node(:filtered_results, @filtered_results),
        errors_node
      ].inject(&:merge)
    end

    # returns the total number of hits for top + all results
    def total_hits_node
      {total_hits: total_hits_count}
    end

    def results_node(key, results)
      {
        key => {
          hits: hit_count_of(results),
          results: results
        }
      }
    end

    def errors_node
      {errors: @errors}
    end

    def total_hits_count
      hit_count_of(@top_results) + hit_count_of(@other_results)
    end

    def hit_count_of(results)
      results.length || 0
    end

    def caching?
      ENV['RACK_ENV'] == 'production' || ENV['CACHING'] == 'true'
    end

    def confirmed?
      params[:confirm] == 'true'
    end

    def perform_load_subs
      current_time = Time.now
      SubscriberFetcher.new.perform
      Time.now - current_time
    end

    def perform_flush_db
      current_time = Time.now
      SubscriberFlush.new.perform
      Time.now - current_time
    end
  end
end
