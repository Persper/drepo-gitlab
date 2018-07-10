# frozen_string_literal: true

class Upload < ActiveRecord::Base
  # Upper limit for foreground checksum processing
  CHECKSUM_THRESHOLD = 100.megabytes
  ALL_STORES = [ObjectStorage::Store::LOCAL, ObjectStorage::Store::REMOTE].freeze

  belongs_to :model, polymorphic: true # rubocop:disable Cop/PolymorphicAssociations

  validates :size, presence: true
  validates :path, presence: true
  validates :model, presence: true
  validates :uploader, presence: true

  scope :with_files_stored_locally, -> { where(store: [nil, ObjectStorage::Store::LOCAL]) }
  scope :with_files_stored_remotely, -> { where(store: [ObjectStorage::Store::REMOTE]) }

  before_save  :calculate_checksum!, if: :foreground_checksummable?
  after_commit :schedule_checksum,   if: :checksummable?

  # as the FileUploader is not mounted, the default CarrierWave ActiveRecord
  # hooks are not executed and the file will not be deleted
  after_destroy :delete_file!, if: -> { uploader_class <= FileUploader }

  def self.hexdigest(path)
    Digest::SHA256.file(path).hexdigest
  end

  class << self
    def get_store_class(store)
      case store
      when ObjectStorage::Store::REMOTE
        # FIXME: this should return class according method name
        Uploads::Fog.new
      when ObjectStorage::Store::LOCAL
        Uploads::Local.new
      else
        raise ObjectStorage::UnknownStoreError
      end
    end

    def get_relation(store)
      case store
      when ObjectStorage::Store::REMOTE
        with_files_stored_remotely
      when ObjectStorage::Store::LOCAL
        with_files_stored_locally
      else
        raise ObjectStorage::UnknownStoreError
      end
    end

    ##
    # FastDestroyAll concerns
    def begin_fast_destroy
      ALL_STORES.each_with_object({}) do |store, result|
        relation = get_relation(store) # rubocop:disable GitlabSecurity/PublicSend
        keys = get_store_class(store).keys(relation)

        result[store] = keys if keys.present?
      end
    end

    ##
    # FastDestroyAll concerns
    def finalize_fast_destroy(keys)
      keys.each do |store, value|
        get_store_class(store).delete_keys(value)
      end
    end
  end

  def absolute_path
    raise ObjectStorage::RemoteStoreError, "Remote object has no absolute path." unless local?
    return path unless relative_path?

    uploader_class.absolute_path(self)
  end

  def calculate_checksum!
    self.checksum = nil
    return unless checksummable?

    self.checksum = Digest::SHA256.file(absolute_path).hexdigest
  end

  def build_uploader(mounted_as = nil)
    uploader_class.new(model, mounted_as || mount_point).tap do |uploader|
      uploader.upload = self
      uploader.retrieve_from_store!(identifier)
    end
  end

  def exist?
    File.exist?(absolute_path)
  end

  def uploader_context
    {
      identifier: identifier,
      secret: secret
    }.compact
  end

  def local?
    return true if store.nil?

    store == ObjectStorage::Store::LOCAL
  end

  private

  def delete_file!
    build_uploader.remove!
  end

  def checksummable?
    checksum.nil? && local? && exist?
  end

  def foreground_checksummable?
    checksummable? && size <= CHECKSUM_THRESHOLD
  end

  def schedule_checksum
    UploadChecksumWorker.perform_async(id)
  end

  def relative_path?
    !path.start_with?('/')
  end

  def uploader_class
    Object.const_get(uploader)
  end

  def identifier
    File.basename(path)
  end

  def mount_point
    super&.to_sym
  end
end
