module Gitlab
  module Dg
    module Model
      def table_name_prefix
        "drepo_"
      end

      def model_name
        @model_name ||= ActiveModel::Name.new(self, nil, self.name.demodulize)
      end
    end
  end
end
