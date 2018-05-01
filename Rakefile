# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'chefstyle'
require 'rubocop/rake_task'
RuboCop::RakeTask.new(:style) do |task|
  task.options << '--display-cop-names'
end

task default: %i[spec style]
