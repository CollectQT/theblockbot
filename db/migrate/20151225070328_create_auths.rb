class CreateAuths < ActiveRecord::Migration
  def change
    create_table :auths do |t|
      t.references :user, index: true, foreign_key: true
      t.string :key
      t.string :secret

      t.timestamps null: false
    end
  end
end
