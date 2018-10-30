module Gitlab
  module Audit
    class MethodLogger
      attr_reader :object, :name, :unique_key, :logger, :singleton_methods, :instance_methods

      def self.stub!(object, logger, base_object: Object,
          unique_key: nil,
          singleton_methods: nil, except_singleton_methods: [],
          instance_methods: nil, except_instance_methods: [])

        singleton_methods ||= object.singleton_methods(false) - base_object.singleton_methods(false)
        instance_methods ||= object.methods(false) - base_object.methods(false)
        unique_key ||= object.to_s

        new(
          object, logger,
          unique_key: unique_key,
          singleton_methods: singleton_methods - except_singleton_methods,
          instance_methods: instance_methods - except_instance_methods,
        ).tap(&:stub!)
      end

      def initialize(object, logger, unique_key:, singleton_methods:, instance_methods:)
        @object = object
        @name = object.to_s
        @unique_key = unique_key
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

      private

      def stub_method!(method_type, method)
        log_method = method(:log)

        old_method = find_method!(object, method_type, method)
        unbound_method = old_method.unbind
        bound_method = unbound_method.bind(object)

        object.send("define_" + method_type, method) do |*args, &block|
          log_method.call(method_type, method, args) do
            bound_method.call(*args, &block)
          end
        end
      end

      def find_method!(object, method_type, method)
        object.send(method_type, method)
      rescue NameError
        find_method!(object.superclass, method_type, method)
      end

      def log(method_type, method, args, &blk)
        in_lock do |first|
          if first
            @logger.info(
              class: name,
              method_type: method_type,
              method: method,
              args: args.map(&:to_s))
          end

          yield
        end
      end

      def in_lock(&blk)
        Thread.current[key] ||= 0
        Thread.current[key] += 1
        begin
          yield(Thread.current[key] == 1)
        ensure
          Thread.current[key] -= 1
        end
      end

      def key
        "method_logger:#{unique_key}"
      end
    end
  end
end
