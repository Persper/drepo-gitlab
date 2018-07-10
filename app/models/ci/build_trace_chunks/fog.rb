# frozen_string_literal: true

module Ci
  module BuildTraceChunks
    class Fog
      include ObjectStorage::Fog

      def keys(relation)
        return [] unless available?

        relation.pluck(:build_id, :chunk_index)
      end

      private

      def key(model)
        [model.build_id, model.chunk_index]
      end

      def key_raw(key_array)
        build_id, chunk_index = key_array

        "tmp/builds/#{build_id.to_i}/chunks/#{chunk_index.to_i}.log"
      end

      def object_store
        Gitlab.config.artifacts.object_store
      end
    end
  end
end
