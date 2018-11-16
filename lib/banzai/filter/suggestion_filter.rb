# frozen_string_literal: true

module Banzai
  module Filter
    class SuggestionFilter < HTML::Pipeline::Filter
      # Class used for tagging elements that should be rendered
      TAG_CLASS = 'js-render-suggestion'.freeze

      # TODO: each code.suggestion should have the data-attributes:
      # - suggested_lines (with line number and text)
      # - can_apply

      def call
        doc.css('pre.code.suggestion > code').each do |el|
          el.add_class(TAG_CLASS)
        end

        doc
      end
    end
  end
end
