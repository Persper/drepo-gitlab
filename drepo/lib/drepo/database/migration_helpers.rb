# frozen_string_literal: true

module Drepo
  module Database
    module MigrationHelpers
      extend ::Gitlab::Utils::Override

      override :postgres_exists_by_name?
      def postgres_exists_by_name?(table, name)
        index_sql = <<~SQL
          SELECT COUNT(*)
          FROM pg_index
          JOIN pg_class i ON (indexrelid=i.oid)
          JOIN pg_class t ON (indrelid=t.oid)
          WHERE i.relname = '#{name}' 
            AND t.relname = '#{table}'
            AND i.relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname = ANY (current_schemas(false)) )
        SQL

        connection.select_value(index_sql).to_i > 0
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
