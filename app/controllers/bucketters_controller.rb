class BuckettersController < ApplicationController
  before_action :set_bucketter, only: [:show, :edit, :update, :destroy]
  before_action :admin_bucketter, only: :destroy
  before_action :correct_bucketter, only: [:edit, :update]
  before_action :signed_in_bucketter, only: [:edit,:update, :destroy]

  helper_method :sort_column, :sort_direction, :offer_sort_column, :offer_sort_direction

  # GET /bucketters
  # GET /bucketters.json
  def index
    @bucketters = Bucketter.all
  end

  # GET /bucketters/1
  # GET /bucketters/1.json
  def show
    bucketter_id = @bucketter.id
    @offers = Offer.where(buyer_id: bucketter_id).order(offer_sort_column + ' ' + offer_sort_direction)
    @books = Book.where(bucketter_id: bucketter_id).order(sort_column + ' ' + sort_direction)
  end

  # GET /bucketters/new
  def new
    @bucketter = Bucketter.new
  end

  # GET /bucketters/1/edit
  def edit
    @bucketter = Bucketter.find(params[id])
  end

  # POST /bucketters
  # POST /bucketters.json
  def create
    @bucketter = Bucketter.new(bucketter_params)
      if @bucketter.save
        BucketterMailer.welcome_email(@bucketter).deliver_now
        flash[:success] = "Welcome to the Book Bucket"
        sign_in @bucketter
        redirect_to @bucketter
      else
        render 'new'
      end
  end

  # PATCH/PUT /bucketters/1
  # PATCH/PUT /bucketters/1.json
  def update
    respond_to do |format|
      if @bucketter.update(bucketter_params)
        format.html { redirect_to @bucketter, notice: 'Bucketter was successfully updated.' }
        format.json { render :show, status: :ok, location: @bucketter }
      else
        format.html { render :edit }
        format.json { render json: @bucketter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bucketters/1
  # DELETE /bucketters/1.json
  def destroy
    @bucketter.destroy
    redirect_to bucketters_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bucketter
      @bucketter = Bucketter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bucketter_params
      params.require(:bucketter).permit(:name, :email, :password,
                                        :password_confirmation,:address,
                                        :first_name,:last_name)
    end

    # Before actions

    # def signed_in_user
    #   redirect_to sigin_url, notice: "Please sign in." unless signed_in?
    # end

    def correct_bucketter
      @bucketter = Bucketter.find(params[:id])
      redirect_to(root_path) unless current_bucketter?(@bucketter)
    end

    def admin_bucketter
      redirect_to(root_path) if current_bucketter.admin?
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
    end

    def sort_column
      %w[created_at title].include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def offer_sort_direction
      %w[asc desc].include?(params[:offer_direction]) ?  params[:offer_direction] : "desc"
    end

    def offer_sort_column
      %w[created_at].include?(params[:offer_sort]) ? params[:offer_sort] : "created_at"
    end
end
