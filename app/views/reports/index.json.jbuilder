json.array!(@reports) do |report|
  json.extract! report, :id, :text, :block_list_id
  json.url report_url(report, format: :json)
end
