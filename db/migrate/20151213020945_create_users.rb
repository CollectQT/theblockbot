class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :display_name
      t.string :site
      t.string :user_id
      t.text :description
      t.string :date_profile_created
      t.integer :times_reported
      t.integer :times_blocked

      t.timestamps null: false
    end
  end
end
