# require 'delayed_job'

# class DelayedJobLogSetup < Delayed::Plugin
#   callbacks do |lifecycle|
#     lifecycle.before(:execute) do |worker|
#       puts "Updating logger"
#       Rails.logger = worker.logger
#       ActiveRecord::Base.logger = worker.logger
#     end
#   end
# end
