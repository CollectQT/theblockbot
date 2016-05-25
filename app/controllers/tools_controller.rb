class ToolsController < ApplicationController

  def hunkerdown
  end

  def blockchain
  end

  def test
    @test_value = ReadFriendsOrFollowersAll.new.read('followers', current_user.id).count
  end

end
