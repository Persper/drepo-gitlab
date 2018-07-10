module Uploads
  class Local
    def available?
      true
    end

    def delete_data(model)
      delete_keys([key(model)])
    end

    def keys(relation)
      return [] unless available?

      relation.pluck(:path)
    end

    def delete_keys(keys)
      keys.each do |key|
        # TODO - validate that expanded filepath is under uploads dir
        path = key_raw(key)

        puts "local: rm -f #{key_raw(key)}"
        FileUtils.rm(path) if exists?(path)
      end
    end

    private

    def exists?(path)
      path.present? && File.exist?(path)
    end

    def key(model)
      # FIXME: sanitization
      model.path
    end

    def key_raw(path)
      File.join(Gitlab.config.uploads.storage_path, path)
    end
  end
end
