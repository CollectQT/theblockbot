class ToolsController < ApplicationController

  def hunkerdown
  end

  def blockchain
  # GET /tools/blockchain
  end

  def blockchain_perform
  # POST /tools/blockchain
    if current_user
      ToolBlockChain.perform_async(current_user.id, params[:user_name])
      notice = "Running a blockchain on #{params[:user_name]}"
    else
      notice = "Not authorized"
    end
    redirect_to :back, notice: notice
  end

  def unblocker
  # GET /tools/unblocker
  end

  def unblocker_perform
  # POST /tools/unblocker
    if current_user
      ToolUnblockAll.perform_async(current_user.id)

      respond_to do |format|
        format.html { redirect_to :back, notice: 'Undoing all blocks on your account!'}
      end
    else
      redirect_to :back
    end
  end

end
