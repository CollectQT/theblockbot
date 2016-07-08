class CreateAuths < ActiveRecord::Migration
  def change
    create_table :auths do |t|
      t.string :encrypted_token
      t.string :encrypted_token_iv
      t.string :encrypted_secret
      t.string :encrypted_secret_iv

      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
