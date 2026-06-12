# frozen_string_literal: true

require_relative 'testing/fixture_loader'
require_relative 'testing/stubs'

module CDEKApiClient
  # Testing module provides helpers and fixtures to make it easy to stub CDEK API calls
  module Testing
    class << self
      def setup!
        require 'webmock'
        WebMock.enable!
      end
    end
  end
end
