require './config/boot'
require './config/environment'

module Clockwork
  every(1.days, 'UnblockProcessor') { UnblockProcessor.perform_async }
end
