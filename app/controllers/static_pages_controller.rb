
class StaticPagesController < ApplicationController
  def index
  end

  def submit
    begin
      @query_text = params[:query]

      @discussit = DiscussItApi.new(@query_text)
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
