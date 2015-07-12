# Tzu Mock

A very simple library for mocking Tzu in RSpec

## Usage

```ruby
TzuMock.success(klass).returns(result) #=> Successful Outcome
TzuMock.invalid(klass).returns(error) #=> Invalid Outcome
TzuMock.failure(klass).returns(error) #=> Failed Outcome
```

Consider this Tzu command:

```ruby
class UpdateUser
  include Tzu
  include Tzu::Validation

  def call(params)
    raise ArgumentError.new('I should be mocked!')
  end
end
```

There are two ways this might need to be mocked. The first happens when the Tzu command is invoked without a block:
```ruby
outcome = UpdateUser.run(params)
```

The second is when the command is invoked with a block, as in this mock controller:
```ruby
class MockController
  attr_reader :method_called

  def update(params = {})
    UpdateUser.run(params) do
      success do |result|
        @method_called = :success
      end

      invalid do |error|
        @method_called = :invalid
      end

      failure do |error|
        @method_called = :failure
      end
    end
  end
end
```

In both cases, the use of TzuMock is the same. First, we'll mock at the simple invocation:
```ruby
describe UpdateUser do
  let(:result) { 'Desired Result' }
  let(:error) { { error: 'ERROR' } }
  let(:params) { { last_name: 'Turner' } }

  context 'success' do
    before { TzuMock.success(UpdateUser).returns(result) }

    let(:outcome) { UpdateUser.run(params) }

    it 'mocks a successful outcome and allows parameters to be verified' do
      expect(outcome.success?).to be true
      expect(outcome.result).to eq result
      expect(outcome.type).to be nil
      expect(UpdateUser).to have_received(:run).with(params)
    end
  end

  context 'invalid' do
    before { TzuMock.invalid(UpdateUser).returns(error) }

    let(:outcome) { UpdateUser.run(params) }

    it 'mocks an invalid outcome and allows parameters to be verified' do
      expect(outcome.success?).to be false
      expect(outcome.result).to eq error
      expect(outcome.type).to eq :validation
      expect(UpdateUser).to have_received(:run).with(params)
    end
  end

  context 'failure' do
    before { TzuMock.failure(UpdateUser).returns(error) }

    let(:outcome) { UpdateUser.run!(params) }

    it 'mocks a failed outcome and allows parameters to be verified' do
      expect(outcome.success?).to be false
      expect(outcome.result).to eq error
      expect(outcome.type).to eq :execution
      expect(UpdateUser).to have_received(:run!).with(params)
    end
  end
end
```

TzuMock mocks both `run` and `run!`, and spies on the class so that you can verify the parameters that were passed.

Next, we'll mock the controller:
```ruby
describe UpdateUser do
  let(:result) { 'Desired Result' }
  let(:error) { { error: 'ERROR' } }
  let(:params) { { last_name: 'Turner' } }

  let(:controller) { MockController.new }

  context 'success' do
    before { TzuMock.success(UpdateUser).returns(result) }

    it 'mocks a successful outcome and allows parameters to be verified' do
      controller.update(params)
      expect(UpdateUser).to have_received(:run).with(params)
      expect(controller.method_called).to eq :success
    end
  end

  context 'invalid' do
    before { TzuMock.invalid(UpdateUser).returns(error) }

    it 'mocks a successful outcome and allows parameters to be verified' do
      controller.update(params)
      expect(UpdateUser).to have_received(:run).with(params)
      expect(controller.method_called).to eq :invalid
    end
  end

  context 'failure' do
    before { TzuMock.failure(UpdateUser).returns(error) }

    it 'mocks a successful outcome and allows parameters to be verified' do
      controller.update(params)
      expect(UpdateUser).to have_received(:run).with(params)
      expect(controller.method_called).to eq :failure
    end
  end
end
```

TzuMock effortlessly passes your desired outcome to the appropriate block.

## Configuration

By default, TzuMock mocks the `run` and `run!` methods,
but you can add more methods to that list if your Tzu classes have another interface.

```ruby
# spec/spec_helper.rb
TzuMock.configure { |config| config.stub_methods = [:go, :go!] }
```
