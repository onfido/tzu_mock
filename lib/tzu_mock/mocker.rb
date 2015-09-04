module TzuMock
  class Mocker
    def initialize(type, klass, rspec_context, method)
      @type, @klass, @rspec_context, @method = type, klass, rspec_context, method
    end

    def mock
      @rspec_context.instance_eval(&mock_proc(@klass, mock_methods, success?, @result, error_type))
      self
    end

    def returns(result)
      @result = result
      mock
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
      TzuMock.configuration.stub_methods
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
end
