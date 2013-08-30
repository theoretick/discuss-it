class SearchesController < ApplicationController
  before_action :set_search, only: [:update, :destroy]

  # GET /searches
  # GET /searches.json
  def index
    @searches = Search.all
  end

  # GET /searches/1
  # GET /searches/1.json
  # def show
  # end

  # # GET /searches/new
  def new
    @search = Search.new
  end

  # # GET /searches/1/edit
  # def edit
  # end

  # POST /searches
  # POST /searches.json
  def create

    user = current_user
    user ||= User.new_guest

    @url = params["search"]["query_url"]

    # links search to user account
    @search = Search.find_or_initialize_by(query_url: @url)
    @search.users << user


    respond_to do |format|
      if @search.save!
        format.html { redirect_to submit_path, :url => @url }
        # format.json { render action: 'show', status: :created, location: @search }
      else
        format.html { redirect_to submit_path, :url => @url, notice: 'Search unable to be created!' }
        # format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /searches/1
  # PATCH/PUT /searches/1.json
  def update

    @url = params[:query_url]
    respond_to do |format|
      if @search.update(search_params)
        format.html { redirect_to @search, notice: 'Search was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        # format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search.destroy
    respond_to do |format|
      format.html { redirect_to searches_path }
      # format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = Search.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.permit(:query_url, :user_id)
    end
end
