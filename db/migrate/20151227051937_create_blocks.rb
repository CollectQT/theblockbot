class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.text :text

      t.references :user, index: true, foreign_key: true, null: false
      t.references :block_list, index: true, foreign_key: true
      t.references :report, foreign_key: true

      t.references :target, references: :user, null: false
      t.references :reporter, references: :user, null: false
      t.references :approver, references: :user, null: false

      t.timestamps null: false
    end
  end
end
