class ChangeShowcaseDefaultToTrue < ActiveRecord::Migration
  def change
    change_column :block_lists, :showcase, :boolean, default: true
  end
end
