class AddPrivateListToBlockList < ActiveRecord::Migration
  def change
    add_column :block_lists, :private_list, :boolean, default: false
  end
end
