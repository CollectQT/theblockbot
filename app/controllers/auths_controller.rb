class AuthsController < ApplicationController
  before_action :set_auth, only: [:show, :edit, :update, :destroy]

  # GET /auths
  # GET /auths.json
  def index
    @auths = Auth.all
  end

  # GET /auths/1
  # GET /auths/1.json
  def show
  end

  # GET /auths/new
  def new
    @auth = Auth.new
  end

  # GET /auths/1/edit
  def edit
  end

  # POST /auths
  # POST /auths.json
  def create
    @auth = Auth.new(auth_params)

    respond_to do |format|
      if @auth.save
        format.html { redirect_to @auth, notice: 'Auth was successfully created.' }
        format.json { render :show, status: :created, location: @auth }
      else
        format.html { render :new }
        format.json { render json: @auth.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /auths/1
  # PATCH/PUT /auths/1.json
  def update
    respond_to do |format|
      if @auth.update(auth_params)
        format.html { redirect_to @auth, notice: 'Auth was successfully updated.' }
        format.json { render :show, status: :ok, location: @auth }
      else
        format.html { render :edit }
        format.json { render json: @auth.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auths/1
  # DELETE /auths/1.json
  def destroy
    @auth.destroy
    respond_to do |format|
      format.html { redirect_to auths_url, notice: 'Auth was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_auth
      @auth = Auth.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def auth_params
      params.require(:auth).permit(:user_id, :key, :secret)
    end
end
