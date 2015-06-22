require 'binding_of_caller'

class TzuMock
  MOCK_METHODS = [:run, :run!]

  class << self
    def method_missing(method, *args)
      return super(method) unless [:success, :invalid, :failure].include? method
      prepare(method, *args)
    end

    def prepare(type, klass, result, method = nil)
      # Get the rspec block context. Will not work if you call TzuMock#prepare directly.
      # Call TzuMock#success, TzuMock#invalid, or TzuMock#failure instead
      rspec_context = binding.of_caller(2).eval('self')

      new(type, klass, result, rspec_context, method).mock
    end
  end

  def initialize(type, klass, result, rspec_context, method)
    @type, @klass, @result, @rspec_context, @method = type, klass, result, rspec_context, method
  end

  def mock
    @rspec_context.instance_eval(&mock_proc(@klass, mock_methods, success?, @result, error_type))
  end

  private

  # Need to pass variables in explicity to give the Proc access to them
  def mock_proc(klass, methods, success, result, type)
    Proc.new do
      methods.each do |method|
        allow(klass).to receive(method) do |&block|
          outcome = Tzu::Outcome.new(success, result, type)
          outcome.handle(&block) if block
          outcome
        end
      end
    end
  end

  def mock_methods
    return [@method] if @method
    MOCK_METHODS
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
