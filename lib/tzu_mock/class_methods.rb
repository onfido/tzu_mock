module TzuMock
  module ClassMethods
    def method_missing(method, *args)
      return super(method) unless [:success, :invalid, :failure].include? method
      prepare(method, *args)
    end

    def prepare(type, klass, method = nil)
      # Get the rspec block context. Will not work if you call TzuMock#prepare directly.
      # Call TzuMock#success, TzuMock#invalid, or TzuMock#failure instead
      rspec_context = binding.of_caller(2).eval('self')

      Mocker.new(type, klass, rspec_context, method).mock
    end
  end
end
