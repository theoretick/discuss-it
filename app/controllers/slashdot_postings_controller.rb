class SlashdotPostingsController < ApplicationController
  before_action :set_slashdot_posting, only: [:show, :edit, :update, :destroy]

  # FIXME: Candidate for removal
  # GET /slashdot_postings
  # GET /slashdot_postings.json
  # def index
  #   @slashdot_postings = SlashdotPosting.all
  # end

  # FIXME: Candidate for removal
  # GET /slashdot_postings/1
  # GET /slashdot_postings/1.json
  # def show
  # end


  # FIXME: probably need url objects?!?
  #  => (posting has_many :urls)
  # return SlashdotPosting attached to query_url
  def find_by_url
    render json: SlashdotPosting.find_by_urls(params[:url])
  end

  # POST /slashdot_postings
  # POST /slashdot_postings.json
  def create
    @slashdot_posting = SlashdotPosting.new(slashdot_posting_params)

    respond_to do |format|
      if @slashdot_posting.save
        format.html { redirect_to @slashdot_posting, notice: 'Slashdot posting was successfully created.' }
        format.json { render action: 'show', status: :created, location: @slashdot_posting }
      else
        format.html { render action: 'new' }
        format.json { render json: @slashdot_posting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /slashdot_postings/1
  # PATCH/PUT /slashdot_postings/1.json
  def update
    respond_to do |format|
      if @slashdot_posting.update(slashdot_posting_params)
        format.html { redirect_to @slashdot_posting, notice: 'Slashdot posting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @slashdot_posting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slashdot_postings/1
  # DELETE /slashdot_postings/1.json
  def destroy
    @slashdot_posting.destroy
    respond_to do |format|
      format.html { redirect_to slashdot_postings_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_slashdot_posting
      @slashdot_posting = SlashdotPosting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def slashdot_posting_params
      params.require(:slashdot_posting).permit(:title, :permalink, :urls)
    end
end
