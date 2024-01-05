module TzuMock
  module ClassMethods
    MISSING_METHODS = %i[success invalid failure].freeze

    def method_missing(method, *args, &block)
      return super unless MISSING_METHODS.include? method

      prepare(method, *args)
    end

    def respond_to_missing?(method_name, include_private = false)
      MISSING_METHODS.include?(method_name) || super
    end

    def prepare(type, klass, method = nil)
      # Get the rspec block context. Will not work if you call TzuMock#prepare directly.
      # Call TzuMock#success, TzuMock#invalid, or TzuMock#failure instead
      rspec_context = binding.of_caller(2).eval("self")

      Mocker.new(type, klass, rspec_context, method).mock
    end
  end
end
