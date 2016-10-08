class ToolsController < ApplicationController


  def blockchain
  # GET /tools/blockchain
  end


  def blockchain_perform(notice: nil, alert: nil)
  # POST /tools/blockchain
    target_user = params[:user_name]

    if current_user
      user_auth = MetaTwitter::Auth.config(current_user)

      if MetaTwitter.too_many_followers?(user_auth, target_user)
        alert = "User #{target_user} has too many followers for blockchain"
      else
        ToolBlockChain.perform_async(current_user.id, target_user)
        notice = "Running a blockchain on #{target_user}"
      end

    else
      alert = "Not authorized"
    end

    redirect_to :back, notice: notice, alert: alert
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
