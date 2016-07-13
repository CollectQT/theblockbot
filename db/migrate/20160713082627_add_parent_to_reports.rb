class AddParentToReports < ActiveRecord::Migration
  def change
    add_column :reports, :parent_id, :integer, default: true, foreign_key: true
  end
end
