json.array!(@blocks) do |block|
  json.extract! block, :id, :text
  json.url block_url(block, format: :json)
end
