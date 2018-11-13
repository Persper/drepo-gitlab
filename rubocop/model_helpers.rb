module RuboCop
  # Module containing helper methods for writing Model cops.
  module ModelHelpers
    def model?(node)
      path = node.location.expression.source_buffer.name

      path.start_with?(File.join(Dir.pwd, 'models'))
    end
  end
end
