class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.references :subscription, index: true, foreign_key: true
      t.references :block_list, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
