# frozen_string_literal: true

module LedgerSync
  module Adaptors
    module Test
      module Vendor
        module Operations
          class Find < Operation::Find
            class Contract < LedgerSync::Adaptors::Contract
              params do
                required(:external_id).maybe(:string)
                required(:ledger_id).filled(:string)
                optional(:display_name).maybe(:string)
                optional(:first_name).maybe(:string)
                optional(:last_name).maybe(:string)
                optional(:email).maybe(:string)
              end
            end

            private

            def operate
              return failure(nil) if resource.ledger_id.nil?

              response = adaptor.find(
                resource: 'vendor',
                id: resource.ledger_id
              )

              success(
                resource: Test::LedgerSerializer.new(resource: resource).deserialize(hash: response),
                response: response
              )
            end
          end
        end
      end
    end
  end
end
