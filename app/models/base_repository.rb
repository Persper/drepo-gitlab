# frozen_string_literal: true

class BaseRepository < ActiveRecord::Base
  self.abstract_class = true

  self.table_name = 'repositories'

  belongs_to :shard
  validates :shard, presence: true

  def shard_name
    shard&.name
  end

  def shard_name=(name)
    self.shard = Shard.by_name(name)
  end
end
