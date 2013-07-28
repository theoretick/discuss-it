require_relative '../slashdot_api'


#----------------------------------------------------------------------
# Slashdot Api Populator for DiscussIt DB: scrapes submissions and urls
# Two run methods:
# - automated maintenance tasks -- through 'whenever' gem and cron
# - manual administrative tasks -- testing and hard DB resets
#----------------------------------------------------------------------
namespace :slashdot do

  VERBOSE = true
  slashdot_api = SlashdotApi.new

  # FIXME: move to helper(?) along with sibling code in slashdot_api
  # if VERBOSE = true, displays output and colorizes it.
  # defaults to 'undef' using env colors
  def display(message, color=:undef)
    if VERBOSE == true
      colorize = {
        :black  => lambda { |text| "\033[30m#{text}\033[0m" },
        :red    => lambda { |text| "\033[31m#{text}\033[0m" },
        :green  => lambda { |text| "\033[32m#{text}\033[0m" },
        :yellow => lambda { |text| "\033[33m#{text}\033[0m" },
        :white  => lambda { |text| "\033[37m#{text}\033[0m" },
        :blue   => lambda { |text| "\033[34m#{text}\033[0m" },
        :undef  => lambda { |text| "#{text}"                }
      }

      # colorize the output, baby
      puts colorize[color].call(message)
    end
  end


  #--------------------------------------------------------------------
  # automated maintenance tasks
  # - to be ran with cron and 'whenever' gem
  # - no output
  #--------------------------------------------------------------------

  desc "get latest postings (automated daily task)"
  task :get_latest => :environment do
    # FIXME: should this limit exist? Assumes <50 new. But a clean run takes ~10 minutes
    slashdot_api.get_postings(50)
  end

  # desc "deletes slashdot listings older than 4 weeks"
  # task :expire_4wk => :environment do
  #   # @urls = Url.where('created_at <= ?', (Time.now - 4.weeks))
  #   @postings = SlashdotPosting.where('created_at <= ?', (Time.now - 4.weeks))
  #   @postings.delete_all
  # end


  #--------------------------------------------------------------------
  # Admin manual management tasks
  #--------------------------------------------------------------------

  desc "clear DB of urls and slashdot_postings. Re-populate last 7 days"
  task :all => [:clear_db, :get_postings]


  desc "clear db of all slashdot_postings and urls"
  task :clear_db => :environment do
    slash_count = SlashdotPosting.all.length
    url_count = Url.all.length

    display "Deleting #{slash_count} slashdot_postings..."
    SlashdotPosting.delete_all
    display "Deleting #{url_count} urls..."
    Url.delete_all

    display "DONE.", :green
  end


  # Benchmark (28jul2013)
  #  - real  0m9.496s
  #  - user  0m3.281s
  #  - sys   0m0.567s
  desc "get ALL recent postings. (Warning: can take a while)"
  task :get_postings => :environment do
    display "WARNING: running with no argument may take a long time (~10m)
    Recommended to use 'get_postings_by' w/ amount instead", :red
    display "Starting slashdot fetch..."
    slashdot_api.get_postings
    display "DONE. Populated the DB.", :green
  end


  # FIXME: worth adding more times? i.e. day & month
  # FIXME: 'time' is semantically odd for a number; use count? amount? range?
  #
  # >> bundle exec rake slashdot:get_postings_by time='12' # lastest 12 postings
  desc "get postings by time: integer or week (w); #=> time='w'"
  task :get_postings_by => :environment do
    time = ENV["time"]

    display "Starting slashdot fetch..."
    slashdot_api.get_postings(time)
    display "\nDONE. Populated the DB.", :green
  end

end
