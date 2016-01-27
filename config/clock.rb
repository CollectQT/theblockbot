require './config/boot'
require './config/environment'

module Clockwork
  every(1.hours, 'UnblockProcessor') { UnblockProcessor.perform_async }
end
