class ToolsController < ApplicationController

  def hunkerdown
  end

  def blockchain
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
