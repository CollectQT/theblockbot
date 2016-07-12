class AddAutoapproveToBlockLists < ActiveRecord::Migration
  def change
    add_column :block_lists, :autoapprove_admin, :boolean, null: false, default: true
    add_column :block_lists, :autoapprove_blocker, :boolean, null: false, default: false
  end
end
