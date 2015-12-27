class CreateBlockLists < ActiveRecord::Migration
  def change
    create_table :block_lists do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :block_lists, :name, :unique => true

  end
end
