require "binding_of_caller"
require "tzu_mock/class_methods"
require "tzu_mock/result_builder"
require "tzu_mock/mocker"
require "tzu_mock/configuration"

module TzuMock
  extend Configuration
  extend ClassMethods
end
