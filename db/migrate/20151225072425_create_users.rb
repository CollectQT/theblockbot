class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :display_name
      t.string :account_created
      t.boolean :default_profile_image
      t.text :description
      t.integer :incoming_follows
      t.integer :outgoing_follows
      t.string :account_id
      t.string :profile_image_url
      t.string :user_name
      t.string :website
      t.string :url
      t.integer :posts
      t.integer :times_reported
      t.integer :times_blocked
      t.integer :reports
      t.integer :blocks

      t.timestamps null: false
    end
  end
end
