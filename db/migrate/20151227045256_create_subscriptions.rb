class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :block_list, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
