# frozen_string_literal: true

module Ci
  class Context < ActiveRecord::Base
    self.abstract_class = true
  end
end
