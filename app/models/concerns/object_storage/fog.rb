# frozen_string_literal: true

module ObjectStorage
  module Fog
    extend ActiveSupport::Concern

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
      raise NotImplementedError
    end

    def delete_keys(keys)
      keys.each do |key|
        puts "fog: rm -f #{key}"
        connection.delete_object(bucket_name, key_raw(key))
      end
    end

    private

    def key(model)
      raise NotImplementedError
    end

    def key_raw(key_array)
      raise NotImplementedError
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
      raise NotImplementedError
    end
  end
end
