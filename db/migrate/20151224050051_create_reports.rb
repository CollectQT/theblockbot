class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.text :text
      t.boolean :processed, null: false, default: false, index: true

      t.references :target, references: :user, null: false, index: true
      t.references :reporter, references: :user, null: false, index: true
      t.references :approver, references: :user, index: true
      t.references :block_list, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
