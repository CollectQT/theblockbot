class ChangeDefaultsForUser < ActiveRecord::Migration
  def change
    change_column :users, :times_reported, :integer, :default => 0
    change_column :users, :times_blocked, :integer, :default => 0
    change_column :users, :reports, :integer, :default => 0
    change_column :users, :blocks, :integer, :default => 0
  end
end
