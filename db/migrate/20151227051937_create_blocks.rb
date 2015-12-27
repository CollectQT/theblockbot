class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :subscription, index: true, foreign_key: true
      t.references :block_list, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
