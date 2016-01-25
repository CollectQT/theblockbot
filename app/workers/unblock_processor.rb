class UnblockProcessor
  include Sidekiq::Worker

  def perform

    puts 'mew'

  end

end
