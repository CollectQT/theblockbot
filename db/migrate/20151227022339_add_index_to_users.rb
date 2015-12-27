class AddIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, [:account_id, :website], :unique => true
  end
end
