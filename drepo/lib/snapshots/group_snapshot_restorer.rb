# frozen_string_literal: true

module Snapshots
  class GroupSnapshotRestorer
    include Gitlab::DrepoImportExport::CommandLineUtil

    attr_accessor :shared
    delegate :snapshot_dir, :json_file, :archive_file, :avatar_file, to: :shared

    def initialize(ipfs_path:, snapshot:)
      @ipfs_path = ipfs_path
      @snapshot = snapshot
      @shared = GroupSnapshotShared.new(@snapshot.author)
    end

    def restore
      FileUtils.mkdir_p(snapshot_dir)

      download_file_from_ipfs

      wait_for_archived_file do
        decompress_archive
      end

      restore_json_file
      restore_group_avatar
    ensure
      FileUtils.rm_rf(snapshot_dir)
      FileUtils.rm_f(archive_file)
    end

    # Exponentially sleep until I/O finishes copying the file
    def wait_for_archived_file
      UserSnapshotShared::MAX_RETRIES.times do |retry_number|
        break if File.exist?(archive_file)

        sleep(2**retry_number)
      end

      yield
    end

    def decompress_archive
      result = untar_zxf(archive: archive_file, dir: snapshot_dir)

      raise "Unable to decompress #{archive_file} into #{snapshot_dir}" unless result

      result
    end

    def download_file_from_ipfs
      unless Ipfs::CatService.new(ipfs_path: @ipfs_path, to_file: archive_file).execute
        raise "Unable to download file #{@ipfs_path} from IPFS"
      end
    end

    def restore_json_file
      data = JSON.parse(File.read(json_file))
      @snapshot.ipfs_path = @ipfs_path
      @snapshot.content = data
      @snapshot.restore_content!
    end

    def restore_group_avatar
      return unless File.file?(avatar_file)

      @snapshot.restore_avatar!(avatar_file)
    end
  end
end
