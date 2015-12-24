class BlockListsController < ApplicationController
  before_action :set_block_list, only: [:show, :edit, :update, :destroy]

  # GET /block_lists
  # GET /block_lists.json
  def index
    @block_lists = BlockList.all
  end

  # GET /block_lists/1
  # GET /block_lists/1.json
  def show
  end

  # GET /block_lists/new
  def new
    @block_list = BlockList.new
  end

  # GET /block_lists/1/edit
  def edit
  end

  # POST /block_lists
  # POST /block_lists.json
  def create
    @block_list = BlockList.new(block_list_params)

    respond_to do |format|
      if @block_list.save
        format.html { redirect_to @block_list, notice: 'Block list was successfully created.' }
        format.json { render :show, status: :created, location: @block_list }
      else
        format.html { render :new }
        format.json { render json: @block_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /block_lists/1
  # PATCH/PUT /block_lists/1.json
  def update
    respond_to do |format|
      if @block_list.update(block_list_params)
        format.html { redirect_to @block_list, notice: 'Block list was successfully updated.' }
        format.json { render :show, status: :ok, location: @block_list }
      else
        format.html { render :edit }
        format.json { render json: @block_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /block_lists/1
  # DELETE /block_lists/1.json
  def destroy
    @block_list.destroy
    respond_to do |format|
      format.html { redirect_to block_lists_url, notice: 'Block list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_block_list
      @block_list = BlockList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def block_list_params
      params.require(:block_list).permit(:name)
    end
end
