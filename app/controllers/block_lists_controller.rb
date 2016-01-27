class BlockListsController < ApplicationController
  before_action :set_block_list, only: [:show, :edit, :update, :destroy, :subscribe, :unsubscribe]

  # GET /block_lists
  def index
    @block_lists = BlockList.all
  end

  # GET /block_lists/1
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
  def create
    @block_list = BlockList.new(block_list_params)

    respond_to do |format|
      if @block_list.save
        format.html { redirect_to @block_list, notice: 'Block list was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /block_lists/1
  def update
    respond_to do |format|
      if @block_list.update(block_list_params)
        format.html { redirect_to @block_list, notice: 'Block list was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # POST /block_lists/1/subscribe
  def subscribe
    Subscription.create(user_id: current_user.id, block_list_id: @block_list.id)
    respond_to do |format|
      format.html { redirect_to block_lists_url, notice: 'Subscribed to '+@block_list.name}
    end
  end

  # DELETE /block_lists/1/subscribe
  def unsubscribe
    Subscription.find_by(user_id: current_user, block_list_id: @block_list.id).delete
    respond_to do |format|
      format.html { redirect_to block_lists_url, notice: 'Unsubscribed from '+@block_list.name}
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
