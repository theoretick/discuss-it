
class StaticPagesController < ApplicationController
  def index
  end

  def submit
    begin
      @query_text = params[:query]

      @discussit = DiscussItApi.new(@query_text)
      @all_results = @discussit.find_all
      @top_results = @discussit.find_top
      # FIXME: remember to delete @s, @r, @h
      @s = @discussit.all_listings.slashdot
      @r = @discussit.all_listings.reddit
      @h = @discussit.all_listings.hn
    rescue DiscussItUrlError => e
      redirect_to :root, :flash => { :error => 'Invalid URL' }
    end
  end

end
