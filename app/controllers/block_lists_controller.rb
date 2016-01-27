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

  # POST /block_list
  def create
    @block_list = BlockList.create(:name => block_list_params['name'])
    Admin.create(block_list: @block_list, user: current_user)

    respond_to do |format|
      if @block_list.save
        format.html { redirect_to block_list_url(@block_list), notice: 'Block List created' }
      else
        format.html { render :new }
      end
    end
  end

  # GET /block_lists/1/edit
  def edit
  end

  # PATCH/PUT /block_lists/1
  def update
    if @block_list.admin? current_user
      respond_to do |format|
        if @block_list.update(block_list_params)
          format.html { redirect_to @block_list, notice: 'Block list was successfully updated.' }
        else
          format.html { render :edit }
        end
      end
    end
  end

  # POST /block_lists/1/subscribe
  def subscribe
    Subscription.add(current_user.id, @block_list.id)
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Subscribed to '+@block_list.name}
    end
  end

  # DELETE /block_lists/1/subscribe
  def unsubscribe
    Subscription.remove(current_user.id, @block_list.id)
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Unsubscribed from '+@block_list.name}
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
