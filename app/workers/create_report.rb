class CreateReport
  include Sidekiq::Worker

  def perform(text, reporter_id)
    user = User.find(reporter_id)
    Report.parse(text, user)
  end

end
