# frozen_string_literal: true

require 'spec_helper'

support :netsuite_helpers

RSpec.describe LedgerSync::Adaptors::Operation do
  include NetSuiteHelpers

  let(:adaptor) { netsuite_adaptor }
  let(:resource) { FactoryBot.create(:customer) }
  let(:operation_class) { adaptor.base_module::Customer::Operations::Create }
  let(:serializer_class) do
    Class.new(LedgerSync::Adaptors::LedgerSerializer) do
      attribute ledger_attribute: :foo,
                resource_attribute: :foo
    end
  end
  let(:validation_contract) do
    Class.new(LedgerSync::Adaptors::Contract) do
      params do
        required(:foo).filled(:string)
      end
    end
  end
  let(:custom_resource_class) do
    Object.const_set(
      "#{test_run_id}TestCustomResource",
      Class.new(LedgerSync::Customer) do
        attribute :foo, type: LedgerSync::Type::String
      end
    )
  end
  let(:operation) do
    operation_class.new(
      adaptor: adaptor,
      resource: resource
    )
  end

  subject { operation }

  it { expect { described_class.new }.to raise_error(NoMethodError) } # Operation is a module

  before do
    stub_customer_create
    stub_customer_find
  end

  subject { operation }

  it { expect { described_class.new }.to raise_error(NoMethodError) } # Operation is a module

  describe '#failure?' do
    it do
      subject.perform
      expect(subject).not_to be_failure
    end
  end

  describe '#ledger_deserializer_class' do
    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        resource: FactoryBot.create(:customer)
      )
      expect(op.ledger_deserializer_class).to eq(LedgerSync::Adaptors::NetSuite::Customer::LedgerDeserializer)
    end

    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        ledger_deserializer_class: nil,
        resource: FactoryBot.create(:customer)
      )
      expect(op.ledger_deserializer_class).to eq(LedgerSync::Adaptors::NetSuite::Customer::LedgerDeserializer)
    end

    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        ledger_deserializer_class: serializer_class,
        resource: FactoryBot.create(:customer)
      )
      expect(op.ledger_deserializer_class).to eq(serializer_class)
    end

    it do
      expect do
        operation_class.new(
          adaptor: netsuite_adaptor,
          ledger_deserializer_class: 'asdf',
          resource: FactoryBot.create(:customer)
        )
      end.to raise_error(LedgerSync::Error::UnexpectedClassError)
    end
  end

  describe '#ledger_serializer_class' do
    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        resource: FactoryBot.create(:customer)
      )
      expect(op.ledger_serializer_class).to eq(LedgerSync::Adaptors::NetSuite::Customer::LedgerSerializer)
    end

    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        ledger_serializer_class: nil,
        resource: FactoryBot.create(:customer)
      )
      expect(op.ledger_serializer_class).to eq(LedgerSync::Adaptors::NetSuite::Customer::LedgerSerializer)
    end

    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        ledger_serializer_class: serializer_class,
        resource: FactoryBot.create(:customer)
      )
      expect(op.ledger_serializer_class).to eq(serializer_class)
    end

    it do
      expect do
        operation_class.new(
          adaptor: netsuite_adaptor,
          ledger_serializer_class: 'asdf',
          resource: FactoryBot.create(:customer)
        )
      end.to raise_error(LedgerSync::Error::UnexpectedClassError)
    end
  end

  describe '#perform' do
    subject { operation.perform }

    it { expect(subject).to be_success }

    it do
      allow(operation).to receive(:operate) { raise LedgerSync::Error.new(message: 'Test') }
      expect(subject).to be_failure
      expect(subject.error.message).to eq('Test')
    end
  end

  describe '#resource' do
    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        resource: FactoryBot.create(:customer)
      )
      expect(op.resource).to be_a(LedgerSync::Customer)
    end

    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        resource: custom_resource_class.new
      )
      expect(op.resource).to be_a(custom_resource_class)
    end

    it do
      expect do
        operation_class.new(
          adaptor: netsuite_adaptor,
          resource: FactoryBot.create(:expense)
        )
      end.to raise_error(LedgerSync::Error::UnexpectedClassError)
    end

    it do
      expect do
        operation_class.new(
          adaptor: netsuite_adaptor,
          resource: nil
        )
      end.to raise_error(LedgerSync::Error::UnexpectedClassError)
    end
  end

  describe '#success?' do
    it do
      subject.perform
      expect(subject).to be_success
    end
  end

  describe '#valid?' do
    it do
      subject.perform
      expect(subject).not_to be_valid
    end
  end

  describe '#validation_contract' do
    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        resource: FactoryBot.create(:customer)
      )
      expect(op.validation_contract).to eq(operation_class::Contract)
    end

    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        validation_contract: nil,
        resource: FactoryBot.create(:customer)
      )
      expect(op.validation_contract).to eq(operation_class::Contract)
    end

    it do
      op = operation_class.new(
        adaptor: netsuite_adaptor,
        validation_contract: validation_contract,
        resource: FactoryBot.create(:customer)
      )
      expect(op.validation_contract).to eq(validation_contract)
    end

    it do
      expect do
        operation_class.new(
          adaptor: netsuite_adaptor,
          validation_contract: 'asdf',
          resource: FactoryBot.create(:customer)
        )
      end.to raise_error(LedgerSync::Error::UnexpectedClassError)
    end
  end
end
