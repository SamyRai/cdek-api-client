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

namespace :schema do
  desc 'Pull and organize the latest CDEK API schemas'
  task :update do
    sh 'ruby pull_cdek_schemas.rb'
  end

  desc 'Generate Ruby Entity classes from OpenAPI schemas'
  task :generate_entities do
    require_relative 'lib/cdek_api_client/generators/entity_generator'
    CDEKApiClient::Generators::EntityGenerator.new.generate_all
  end
end