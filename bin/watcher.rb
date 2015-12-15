TwitterClient.Stream.filter(track: 'minecraft') do |object|
  if object.is_a?(Twitter::Tweet)
    puts object.text
    Report.create(text: object.text)
  end
end
