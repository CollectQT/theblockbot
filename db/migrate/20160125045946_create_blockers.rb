class CreateBlockers < ActiveRecord::Migration
  def change
    create_table :blockers do |t|
      t.string :type
      t.references :user, index: true, foreign_key: true
      t.references :block_list, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
