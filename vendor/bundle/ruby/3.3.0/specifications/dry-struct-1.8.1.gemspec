# -*- encoding: utf-8 -*-
# stub: dry-struct 1.8.1 ruby lib

Gem::Specification.new do |s|
  s.name = "dry-struct".freeze
  s.version = "1.8.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "bug_tracker_uri" => "https://github.com/dry-rb/dry-struct/issues", "changelog_uri" => "https://github.com/dry-rb/dry-struct/blob/main/CHANGELOG.md", "funding_uri" => "https://github.com/sponsors/hanami", "source_code_uri" => "https://github.com/dry-rb/dry-struct" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Hanakai team".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.description = "Typed structs and value objects".freeze
  s.email = ["info@hanakai.org".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "LICENSE".freeze, "README.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "LICENSE".freeze, "README.md".freeze]
  s.homepage = "https://dry-rb.org/gems/dry-struct".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1.0".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Typed structs and value objects".freeze

  s.installed_by_version = "3.5.22".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.6".freeze])
  s.add_runtime_dependency(%q<dry-core>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<dry-types>.freeze, ["~> 1.8".freeze, ">= 1.8.2".freeze])
  s.add_runtime_dependency(%q<ice_nine>.freeze, ["~> 0.11".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<yard>.freeze, [">= 0".freeze])
end
