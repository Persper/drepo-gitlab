# frozen_string_literal: true

module Drepo
  module Database
    module MigrationHelpers
      extend ::Gitlab::Utils::Override

      override :index_exists_by_name?
      # Assume rails > 5
      def index_exists_by_name?(table, index)
        indexes(table).map(&:name).include?(index.to_s)
      end

      override :disable_statement_timeout
      def disable_statement_timeout
        unless ::Gitlab::Database.postgresql?
          if block_given?
            yield
          end

          return
        end

        if block_given?
          # Ensure switch tenant back
          tenant = Apartment::Tenant.current
          begin
            execute('SET statement_timeout TO 0')

            yield
          ensure
            execute('RESET ALL')
            Apartment::Tenant.switch! tenant
          end
        else
          unless transaction_open?
            raise <<~ERROR
              Cannot call disable_statement_timeout() without a transaction open or outside of a transaction block.
              If you don't want to use a transaction wrap your code in a block call:

              disable_statement_timeout { # code that requires disabled statement here }

              This will make sure statement_timeout is disabled before and reset after the block execution is finished.
            ERROR
          end

          execute('SET LOCAL statement_timeout TO 0')
        end
      end
    end
  end
end
