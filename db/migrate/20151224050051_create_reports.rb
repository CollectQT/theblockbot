class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.text :text
      t.references :block_list, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
