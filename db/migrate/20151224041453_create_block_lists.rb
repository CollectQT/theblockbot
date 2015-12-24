class CreateBlockLists < ActiveRecord::Migration
  def change
    create_table :block_lists do |t|
      t.text :name

      t.timestamps null: false
    end
  end
end
