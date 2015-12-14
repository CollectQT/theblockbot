json.array!(@users) do |user|
  json.extract! user, :id, :name, :display_name, :site, :user_id, :description, :date_profile_created, :times_reported, :times_blocked
  json.url user_url(user, format: :json)
end
