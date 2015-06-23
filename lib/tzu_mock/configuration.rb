module TzuMock
  module Configuration
    def configuration
      @configuration ||= Config.new
    end

    def configure
      yield(configuration)
    end
  end

  class Config
    DEFAULT_MOCK_METHODS = [:run, :run!]

    def stub_methods
      @stub_methods ||= DEFAULT_MOCK_METHODS
    end

    def stub_methods=(methods)
      @stub_methods = stub_methods + methods
    end
  end
end
