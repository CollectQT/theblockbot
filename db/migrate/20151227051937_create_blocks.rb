class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.datetime :expires

      t.references :user, index: true, foreign_key: true, null: false
      t.references :report, foreign_key: true, index: true
      t.references :target, references: :user, null: false, index: true

      t.timestamps null: false
    end
  end
end
