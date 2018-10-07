# frozen_string_literal: true

module Ci
  module BuildTraceChunks
    class Fog
      def available?
        object_store.enabled
      end

      def data(model)
        model_key = key(model)

        connection.get_object(bucket_name, key_raw(model_key))[:body]
      end

      def set_data(model, data)
        model_key = key(model)

        connection.put_object(bucket_name, key_raw(model_key), data)
      end

      def delete_data(model)
        delete_keys([key(model)])
      end

      def keys(relation)
        return [] unless available?

        relation.pluck(:build_id, :chunk_index)
      end

      def delete_keys(keys)
        keys.each do |key|
          connection.delete_object(bucket_name, key_raw(key))
        end
      end

      private

      def key(model)
        [model.build_id, model.chunk_index]
      end

      def key_raw(key_array)
        build_id, chunk_index = key_array

        "tmp/builds/#{build_id.to_i}/chunks/#{chunk_index.to_i}.log"
      end

      def bucket_name
        return unless available?

        object_store.remote_directory
      end

      def connection
        return unless available?

        @connection ||= ::Fog::Storage.new(object_store.connection.to_hash.deep_symbolize_keys)
      end

      def object_store
        Gitlab.config.artifacts.object_store
      end
    end
  end
end
