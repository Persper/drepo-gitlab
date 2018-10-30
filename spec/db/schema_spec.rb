# frozen_string_literal: true

require 'spec_helper'

describe 'Database schema' do
  let(:connection) { ActiveRecord::Base.connection }
  let(:tables) { connection.tables }

  context 'for table' do
    ActiveRecord::Base.connection.tables.sort.each do |table|
      describe table do
        let(:indexes) { connection.indexes(table) }
        let(:foreign_keys) { connection.foreign_keys(table) }

        context 'all foreign keys' do
          # for index to be effective, the FK constraint has to be at first place
          it 'are indexed' do
            first_indexed_column = indexes.map(&:columns).map(&:first)
            foreign_keys_columns = foreign_keys.map(&:column)

            expect(first_indexed_column.uniq).to include(*foreign_keys_columns)
          end
        end
      end
    end
  end
end
