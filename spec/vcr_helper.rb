require 'vcr'


VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  c.default_cassette_options = {
    :record => :new_episodes,
    :match_requests_on => [ :method, :path, :query ]
  }

  c.before_record do |r|
    r.request.headers.except!(
      "Authorization","Accept-Encoding"
    )
    r.response.headers.except!(
      "Server", "Set-Cookie", "X-Connection-Hash", "X-Transaction",
      "Cache-Control", "Content-Length", "Date", "Expires", "Last-Modified",
      "Pragma", "Strict-Transport-Security", "X-Access-Level",
      "X-Content-Type-Options", "X-Frame-Options", "X-Rate-Limit-Remaining",
      "X-Rate-Limit-Reset", "X-Response-Time", "X-Twitter-Response-Tags",
      "X-Xss-Protection", "Content-Disposition", "Content-Type",
    )
  end
end
