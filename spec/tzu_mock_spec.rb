require 'spec_helper'

describe TzuMock do
  let(:result) { 'Desired Result' }
  let(:error) { { error: 'ERROR' } }
  let(:params) { { last_name: 'Turner' } }

  class UpdateUser
    include Tzu
    include Tzu::Validation

    def call(params)
      raise ArgumentError.new('I should be mocked!')
    end
  end

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

  context 'configuration' do
    context 'when no stub methods have been added' do
      it 'configures the default stub methods' do
        expect(TzuMock.configuration.stub_methods).to eq TzuMock::Config::DEFAULT_MOCK_METHODS
      end
    end

    context 'when stub methods have been added' do
      let(:stub_methods) { [:go, :go!] }

      before do
        TzuMock.configure { |config| config.stub_methods = stub_methods }
      end

      it 'appends the configured methods to the default stub methods' do
        expect(TzuMock.configuration.stub_methods.sort).to eq (TzuMock::Config::DEFAULT_MOCK_METHODS + stub_methods).sort
      end
    end
  end

  context 'result builder' do
    let(:outcome) { UpdateUser.run!(params) }

    before { TzuMock.success(UpdateUser).returns(result) }

    context 'hash' do
      let(:result) { {name: 'me!'} }
      it 'returns hash attributes as methods' do
        expect(outcome.result.is_a?(Hash)).to be_truthy
        expect(outcome.result.name).to eq(result[:name])
      end
    end
    context 'array' do
      context 'contains hash' do
        let(:result) { [{name: 'other'}] }
        it 'responds to name' do
          expect(outcome.result.first.is_a?(Hash)).to be_truthy
          expect(outcome.result.first.name).to eq(result.first[:name])
        end
      end
      context 'does not ctonain hash' do
        let(:result) { ['me'] }
        it 'responds to name' do
          expect(outcome.result.first.is_a?(String)).to be_truthy
          expect(outcome.result).to eq(result)
        end
      end
    end
    context 'string' do
      let(:result) { 'me!' }
      it 'responds to name' do
        expect(outcome.result.is_a?(String)).to be_truthy
        expect(outcome.result).to eq(result)
      end
    end
  end

  context 'when invocation does not have a block' do
    context 'success' do
      before { TzuMock.success(UpdateUser).returns(result) }

      let(:outcome) { UpdateUser.run!(params) }

      it 'mocks a successful outcome and allows parameters to be verified' do
        expect(outcome.success?).to be true
        expect(outcome.result).to eq result
        expect(outcome.type).to be nil
        expect(UpdateUser).to have_received(:run!).with(params)
      end
    end

    context 'invalid' do
      before { TzuMock.invalid(UpdateUser).returns(error) }

      let(:outcome) { UpdateUser.run!(params) }

      it 'mocks an invalid outcome and allows parameters to be verified' do
        expect(outcome.success?).to be false
        expect(outcome.result).to eq error
        expect(outcome.type).to eq :validation
        expect(UpdateUser).to have_received(:run!).with(params)
      end
    end

    context 'failure' do
      before { TzuMock.failure(UpdateUser).returns(error) }

      let(:outcome) { UpdateUser.run(params) }

      it 'mocks a failed outcome and allows parameters to be verified' do
        expect(outcome.success?).to be false
        expect(outcome.result).to eq error
        expect(outcome.type).to eq :execution
        expect(UpdateUser).to have_received(:run).with(params)
      end
    end
  end

  context 'when invocation has a block' do
    context 'success' do
      before { TzuMock.success(UpdateUser).returns(result) }

      let(:controller) { MockController.new }

      it 'mocks a successful outcome and allows parameters to be verified' do
        controller.update(params)
        expect(UpdateUser).to have_received(:run).with(params)
        expect(controller.method_called).to eq :success
      end
    end

    context 'invalid' do
      before { TzuMock.invalid(UpdateUser).returns(error) }

      let(:controller) { MockController.new }

      it 'mocks a successful outcome and allows parameters to be verified' do
        controller.update(params)
        expect(UpdateUser).to have_received(:run).with(params)
        expect(controller.method_called).to eq :invalid
      end
    end

    context 'failure' do
      before { TzuMock.failure(UpdateUser).returns(error) }

      let(:controller) { MockController.new }

      it 'mocks a successful outcome and allows parameters to be verified' do
        controller.update(params)
        expect(UpdateUser).to have_received(:run).with(params)
        expect(controller.method_called).to eq :failure
      end
    end
  end

  context 'TzuMock receive no return result' do
    context 'success' do
      before { TzuMock.success(UpdateUser) }

      let(:outcome) { UpdateUser.run!(params) }

      it 'mocks a successful outcome and allows parameters to be verified' do
        expect(outcome.success?).to be true
        expect(outcome.type).to be nil
        expect(UpdateUser).to have_received(:run!).with(params)
      end
    end

    context 'invalid' do
      before { TzuMock.invalid(UpdateUser) }

      let(:outcome) { UpdateUser.run!(params) }

      it 'mocks an invalid outcome and allows parameters to be verified' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :validation
        expect(UpdateUser).to have_received(:run!).with(params)
      end
    end

    context 'failure' do
      before { TzuMock.failure(UpdateUser) }

      let(:outcome) { UpdateUser.run(params) }

      it 'mocks a failed outcome and allows parameters to be verified' do
        expect(outcome.success?).to be false
        expect(outcome.type).to eq :execution
        expect(UpdateUser).to have_received(:run).with(params)
      end
    end
  end
end
