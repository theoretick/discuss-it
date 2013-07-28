require_relative '../slashdot_api'


#----------------------------------------------------------------------
# FIXME: should run daily-ish -- install 'whenever' gem
#----------------------------------------------------------------------
namespace :slashdot do

  slashdot_api = SlashdotApi.new

  desc "clear DB of urls and slashdot_postings. Re-populate last 7 days"
  task :all => [:clear_db, :get_postings]


  desc "clear db of postings"
  task :clear_db => :environment do
    slash_count = SlashdotPosting.all.length
    url_count = Url.all.length

    puts "Deleting #{slash_count} slashdot_postings..."
    SlashdotPosting.delete_all
    puts "Deleting #{url_count} urls..."
    Url.delete_all

    puts "DONE."
  end


  desc "get recent postings"
  task :get_postings => :environment do
    puts "Starting slashdot fetch..."
    slashdot_api.get_postings
    puts "DONE. Populated the DB..."
  end


  # FIXME: worth adding more times? i.e. day & month
  # FIXME: 'time' is semantically odd for a number; use count? amount? range?
  #
  # >> bundle exec rake slashdot:get_postings_by time='12'
  # >> bundle exec rake slashdot:get_postings_by time='w'
  desc "get postings by time: integer, week (w), or year (y); #=> time='w'"
  task :get_postings_by => :environment do
    time = ENV["time"]
    puts "Starting slashdot fetch..."
    slashdot_api.get_postings(time)
    puts "DONE. Populated the DB..."
  end

end
