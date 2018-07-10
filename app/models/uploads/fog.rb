# frozen_string_literal: true

module Uploads
  class Fog
    include ObjectStorage::Fog

    def keys(relation)
      return [] unless available?

      relation.pluck(:path)
    end

    private

    def key(model)
      model.path
    end

    def key_raw(path)
      path
    end

    def object_store
      Gitlab.config.uploads.object_store
    end
  end
end
