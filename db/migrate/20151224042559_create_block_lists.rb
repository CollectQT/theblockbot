class CreateBlockLists < ActiveRecord::Migration
  def change
    create_table :block_lists do |t|
      t.string :name, null: false
      t.boolean :private_list, null: false, default: false
      t.boolean :show_blocks, null: false, default: true

      t.timestamps null: false
    end

    add_index :block_lists, :name, :unique => true

  end
end
