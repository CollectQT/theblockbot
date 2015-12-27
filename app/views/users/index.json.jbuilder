json.array!(@users) do |user|
  json.extract! user, :id, :display_name, :account_created, :default_profile_image, :description, :incoming_follows, :outgoing_follows, :account_id, :profile_image_url, :user_name, :website, :posts, :times_reported, :times_blocked, :reports, :blocks
  json.url user_url(user, format: :json)
end
