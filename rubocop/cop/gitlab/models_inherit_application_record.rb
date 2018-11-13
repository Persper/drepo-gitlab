require_relative '../../model_helpers'

module RuboCop
  module Cop
    module Models
      # This cop checks for models that extend from ActiveRecord::Base
      #
      # @example
      #   # bad
      #   class MyModel < ActiveRecord::Base
      #
      #   # good
      #   class MyModel < ApplicationRecord
      class ModelsInheritApplicationRecord < RuboCop::Cop::Cop
        include ModelHelpers

        MESSAGE = <<~EOL.freeze
          Models should not inherit from ActiveRecord::Base anymore. Please inherit ApplicationRecord instead

          Rails 5 upgrade item 5.2 dictates all Models inherit from ApplicationRecord

          https://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#active-record-models-now-inherit-from-applicationrecord-by-default
        EOL


        def_node_matcher :extends_activerecord_base?, <<~PATTERN
          (class
            (const nil ...)
            (const
              (const nil :ActiveRecord) :Base) nil)
        PATTERN

        def on_send(node)
          return unless model?(node)

          add_offense(node, location: :expression, message: MESSAGE) if extends_activerecord_base?(node)
        end
      end
    end
  end
end
