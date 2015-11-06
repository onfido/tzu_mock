require 'hashie'

module TzuMock
  class HashResult < Hash
    include Hashie::Extensions::MethodAccess

    def initialize(attributes)
      update(attributes)
    end
  end

  class ResultBuilder
    class << self
      def build(result)
        name = "build_#{result.class.name.downcase}".to_sym
        if respond_to?(name, true)
          send(name, result)
        else
          result
        end
      end

      private

      def build_hash(result)
        HashResult.new(result)
      end

      def build_array(result)
        result.map { |r| r.is_a?(Hash) ? build_hash(r) : r}
      end
    end
  end
end
