# frozen_string_literal: true

module Drepo
  module Snapshot
    class BaseSnapshot
      attr_reader :drepo_id, :last_drepo_id, :root_id, :from_schema, :to_schema, :connection

      # schemas
      PUBLIC = 'public'
      DREPO_PROJECT_PENDING = 'drepo_project_pending'
      DREPO_PROJECT_COMPLETED = 'drepo_project_completed'
      DREPO_PROJECT_RESTORING = 'drepo_project_restoring'

      def initialize(drepo_id:, last_drepo_id: nil, root_id:, from_schema: PUBLIC, to_schema: DREPO_PROJECT_PENDING)
        @drepo_id = drepo_id
        @last_drepo_id = last_drepo_id
        @root_id = root_id
        @from_schema = from_schema
        @to_schema = to_schema
        @connection = ActiveRecord::Base.connection
      end

      def generate_snapshot_sql(relation, returning: nil, select_statement: nil)
        model_klass = relation.klass
        table_name = model_klass.table_name
        column_names = model_klass.column_names
        column_names_str = column_names.map { |v| connection.quote_column_name(v) }.join(',')
        primary_key = model_klass.primary_key

        insert_statement = %Q{
          INSERT INTO #{to_schema}.#{table_name} (#{column_names_str},#{extend_insert_columns(table_name)})
        }

        where_statement = ""
        where_clause_hash = relation.where_clause.to_h
        unless where_clause_hash.empty?
          where_statement = where_clause_hash.to_a.map do |arr|
            case arr[1]
            when Array
              if arr[1].empty?
                "#{arr[0]} = NULL"
              else
                "#{arr[0]} IN (#{arr[1].flatten.map! { |v| connection.quote(v) }.join(',')})"
              end
            else
              "#{arr[0]} = #{connection.quote(arr[1])}"
            end
          end
          where_statement = "WHERE #{where_statement.join(' AND ')}"
        end

        select_statement = select_statement.presence ||
          %Q{
            SELECT #{column_names_str}
            FROM #{from_schema}.#{table_name}
            #{where_statement}
          }

        select_statement = %Q{
          SELECT t.*,#{extend_select_columns(table_name)}
          FROM (#{select_statement}) t
        }

        on_conflict_do = if primary_key.blank?
                           "ON CONFLICT DO NOTHING"
                         else
                           %Q{
                             ON CONFLICT (#{primary_key})
                             DO UPDATE SET #{column_names.map { |name| "#{name} = EXCLUDED.#{name}" }.join(',')}
                           }
                         end

        returning ||= primary_key
        returning_statement = case returning
                              when nil
                                ""
                              when Array
                                "RETURNING #{returning.map { |v| connection.quote_column_name(v.to_s) }.join(',')}"
                              else
                                "RETURNING #{connection.quote_column_name(returning.to_s)}"
                              end

        sql = %Q{
          #{insert_statement}
          #{select_statement}
          #{on_conflict_do}
          #{returning_statement};
        }

        sql
      end

      def extend_insert_columns(table_name)
        if has_timestamp?(table_name)
          %Q{"original_created_at","original_updated_at","drepo_id"}
        else
          '"drepo_id"'
        end
      end

      def extend_select_columns(table_name)
        if has_timestamp?(table_name)
          %Q{"created_at","updated_at",#{drepo_id}}
        else
          drepo_id
        end
      end

      def timestamp_tables
        sql = %Q{
          SELECT DISTINCT table_name
          FROM information_schema.columns
          WHERE table_schema='public'
            AND column_name='updated_at'
        }
        @timestamp_tables ||= connection.query(sql).flatten
      end

      def has_timestamp?(table_name)
        timestamp_tables.include? table_name
      end

      # should overwrite by subclass
      def all_tables
        []
      end

      def clear_last_drepo
        return if last_drepo_id.blank? || all_tables.empty?

        connection.execute(%Q{
          do $$
          declare
              r record;
          begin
          for r in
              select
                'DELETE FROM #{to_schema}.' || T.myTable || ' WHERE #{to_schema}.' || T.myTable || '.drepo_id = #{last_drepo_id}' as script
              from
                (
                  SELECT DISTINCT table_name as myTable FROM information_schema.columns WHERE table_schema='#{to_schema}' AND column_name='drepo_id' AND table_name NOT IN ('ar_internal_metadata', 'schema_migrations')
                ) t
          loop
          execute r.script;
          end loop;
          end;
          $$;
        })
      end
    end
  end
end