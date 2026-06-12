# frozen_string_literal: true

require 'bundler/gem_tasks'

# Default task
task default: %i[test rubocop]

# Test task
task :test do
  sh 'bundle exec rspec'
end

# RuboCop task
task :rubocop do
  sh 'bundle exec rubocop'
end

# Bundle audit task for security scanning
task :audit do
  sh 'bundle exec bundle audit check --update'
end
