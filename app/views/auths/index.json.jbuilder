json.array!(@auths) do |auth|
  json.extract! auth, :id, :user_id, :key, :secret
  json.url auth_url(auth, format: :json)
end
