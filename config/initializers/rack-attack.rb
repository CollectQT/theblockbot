class Rack::Attack

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  Rack::Attack.throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.ip unless req.path.start_with? '/assets'
  end

  ### Prevent Brute-Force Login Attacks ###

  # We have oauth only logins, but people still try so limit them
  # for the sake of conserving resources
  Rack::Attack.throttle('logins/ip', :limit => 15, :period => 60.seconds) do |req|
    req.ip if req.path.start_with? '/blocklists'
    # ENV['RATE_LIMIT'].split(',').each do |route|
    #   req.ip if req.path.start_with? route
    # end
  end

end
