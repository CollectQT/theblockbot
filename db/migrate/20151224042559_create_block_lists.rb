class CreateBlockLists < ActiveRecord::Migration
  def change
    create_table :block_lists do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :hidden, null: false, default: false
      t.boolean :show_blocks, null: false, default: true
      t.integer :expires, default: 365

      t.timestamps null: false
    end

    add_index :block_lists, :name, :unique => true

  end
end
