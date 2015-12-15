json.array!(@reports) do |report|
  json.extract! report, :id, :text
  json.url report_url(report, format: :json)
end
