require 'binding_of_caller'

class TzuMock
  class << self
    def method_missing(method, *args)
      return super(method) unless [:success, :invalid, :failure].include? method
      prepare(method, *args)
    end

    def prepare(type, klass, method, result)
      # Get the rspec block context. Will not work if you call TzuMock#prepare directly.
      # Call TzuMock#success, TzuMock#invalid, or TzuMock#failure instead
      rspec_context = binding.of_caller(2).eval('self')

      new(type, klass, method, result, rspec_context).mock
    end
  end

  def initialize(type, klass, method, result, rspec_context)
    @type, @klass, @method, @result, @rspec_context = type, klass, method, result, rspec_context
  end

  def mock
    @rspec_context.instance_eval(&mock_proc(@klass, @method, success?, @result, error_type))
  end

  private

  def mock_proc(klass, method, success, result, type)
    Proc.new do
      allow(klass).to receive(method) do |&block|
        outcome = Tzu::Outcome.new(success, result, type)
        outcome.handle(&block) if block
        outcome
      end
    end
  end

  def success?
    @type == :success
  end

  def error_type
    case @type
    when :success
      nil
    when :invalid
      :validation
    when :failure
      :execution
    else
      raise ArgumentError.new('Invalid type, must be :success, :invalid, or :failure')
    end
  end
end
