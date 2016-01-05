class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
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
      t.integer :times_reported, :default => 0
      t.integer :times_blocked, :default => 0
      t.integer :reports_created, :default => 0
      t.integer :reports_approved, :default => 0

      t.timestamps null: false
    end

    add_index :users, [:account_id, :website], :unique => true

  end
end
