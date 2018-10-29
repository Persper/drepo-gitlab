module Gitlab
  module Audit
    class MethodLogger
      attr_reader :object, :object_name, :logger, :singleton_methods, :instance_methods

      def self.stub!(object, logger, base_object: Object,
          singleton_methods: nil, except_singleton_methods: [],
          instance_methods: nil, except_instance_methods: [])

        singleton_methods ||= object.singleton_methods(false) - base_object.singleton_methods(false)
        instance_methods ||= object.methods(false) - base_object.methods(false)

        new(
          object, logger,
          singleton_methods: singleton_methods - except_singleton_methods,
          instance_methods: instance_methods - except_instance_methods,
        ).stub!
      end

      def initialize(object, logger, singleton_methods:, instance_methods:)
        @object = object
        @object_name = object.to_s
        @logger = logger
        @singleton_methods = singleton_methods
        @instance_methods = instance_methods
      end

      def stub!
        singleton_methods.each do |method|
          stub_method!('singleton_method', method)
        end

        instance_methods.each do |method|
          stub_method!('method', method)
        end
      end

      def stub_method!(method_type, method)
        old_method = object.send(method_type, method)
        method_logger = self

        object.send("define_" + method_type, method) do |*args, &block|
          nested = method_logger.object_value_add(1)

          begin
            if nested == 1
              method_logger.logger.info(
                class: method_logger.object.to_s,
                method_type: method_type,
                method: method,
                args: args.map(&:to_s))
            end

            old_method.call(*args, &block)
          ensure
            method_logger.object_value_add(-1)
          end
        end
      end

      def object_value_add(value)
        Thread.current["#{object_key}"] ||= 0
        Thread.current["#{object_key}"] += value
      end

      def object_key
        "method_logger:#{object_name}"
      end
    end
  end
end
