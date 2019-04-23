# frozen_string_literal: true

module Gitlab
  module DrepoImportExport
    class Serialization
      def as_json(model, root, options = nil)
        hash, fingerprint_hash, _fingerprint = serializable_hash(model, root, {}, options)
        hash['_fingerprint_hash'] = fingerprint_hash
        hash
      end

      private

      def serializable_hash(model, fingerprint_parent, fingerprint_hash, options = nil)
        options ||= {}

        attribute_names = model.attributes.keys
        if (only = options[:only])
          attribute_names &= Array(only).map(&:to_s)
        elsif (except = options[:except])
          attribute_names -= Array(except).map(&:to_s)
        end

        hash = {}
        attribute_names.each { |n| hash[n] = model.try!(n) }
        Array(options[:methods]).each { |m| hash[m.to_s] = model.try!(m) }

        fingerprint = ''

        unless options[:inline]
          fingerprint_name = "#{fingerprint_parent}:#{model.try!(id_attribute)}"

          serializable_add_includes(model, options) do |association, records, opts|
            association_result, fingerprint_hash, association_fingerprint = serializable_association(
              records,
              opts,
              "#{fingerprint_name}:#{association}",
              fingerprint_hash
            )
            fingerprint += association_fingerprint
            hash[association.to_s] = association_result
          end

          fingerprint += generate_fingerprint(model)

          if options[:diffs]
            fingerprint_hash[fingerprint_name] = Digest::SHA256.hexdigest(fingerprint)
            fingerprint_hash["#{fingerprint_name}:STRING"] = fingerprint
          end
        end

        [hash, fingerprint_hash, fingerprint]
      end

      def serializable_add_includes(model, options = {})
        return unless (includes = options[:include])

        unless includes.is_a?(Hash)
          includes = Hash[Array(includes).map { |n| n.is_a?(Hash) ? n.to_a.first : [n, {}] }]
        end

        includes.each do |association, opts|
          if (records = model.try!(association))
            yield association, records, opts
          end
        end
      end

      def serializable_association(records, opts, fingerprint_name, fingerprint_hash)
        if records.respond_to?(:to_ary)
          fingerprint = ''

          association_result = if opts[:inline]
                                 records.to_ary.map do |a|
                                   result, fingerprint_hash, _f = serializable_hash(a, fingerprint_name, fingerprint_hash, opts)
                                   result
                                 end
                               else
                                 records.to_ary.map do |a|
                                   s, fingerprint_hash, f = serializable_hash(a, fingerprint_name, fingerprint_hash, opts)
                                   fingerprint += f
                                   [a.try!(id_attribute), s]
                                 end.to_h
                               end

          [association_result, fingerprint_hash, fingerprint]
        else
          serializable_hash(records, fingerprint_name, fingerprint_hash, opts)
        end
      end

      def generate_fingerprint(model)
        fingerprint = model.try!(id_attribute)

        if model.respond_to? 'updated_at'
          "#{fingerprint}@#{model.try!('updated_at').to_f}"
        elsif model.respond_to? 'created_at'
          "#{fingerprint}@#{model.try!('created_at').to_f}"
        else
          fingerprint
        end
      end

      def id_attribute
        @id_attribute ||= 'drepo_uuid'
      end
    end
  end
end
