# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      class Normalizer
        def initialize(jobs_config)
          @jobs_config = jobs_config
        end

        def normalize_jobs
          extract_parallelized_jobs!
          return @jobs_config if @parallelized_jobs.empty?

          parallelized_config = parallelize_jobs
          parallelize_dependencies(parallelized_config)
        end

        private

        def extract_parallelized_jobs!
          @parallelized_jobs = {}

          @jobs_config.each do |job_name, config|
            if config[:parallel]
              @parallelized_jobs[job_name] = self.class.parallelize_job_names(job_name, config[:parallel])
            end
          end

          @parallelized_jobs
        end

        def parallelize_jobs
          condition = lambda { |job_name, _| @parallelized_jobs.key?(job_name) }
          replacement = lambda do |job_name, config|
            @parallelized_jobs[job_name].collect { |name, index| [name.to_sym, config.merge(name: name, instance: index)] }
          end

          self.class.replace_in_hash(@jobs_config, condition, replacement)
        end

        def parallelize_dependencies(parallelized_config)
          parallelized_job_names = @parallelized_jobs.keys.map(&:to_s)
          condition = lambda { |_, config| config[:dependencies] && (config[:dependencies] & parallelized_job_names).any? }
          replacement = lambda do |job_name, config|
            intersection = config[:dependencies] & parallelized_job_names
            deps = intersection.map { |dep| @parallelized_jobs[dep.to_sym].map(&:first) }.flatten

            [[job_name, config.merge(dependencies: deps)]]
          end

          self.class.replace_in_hash(parallelized_config, condition, replacement)
        end

        def self.parallelize_job_names(name, total)
          Array.new(total) { |index| ["#{name} #{index + 1}/#{total}", index + 1] }
        end

        def self.replace_in_hash(original_hash, condition_predicate, replacement_predicate)
          original_hash.each_with_object({}) do |(key, value), hash|
            if condition_predicate.call(key, value)
              replacement_predicate.call(key, value).each { |repl_key, repl_value| hash[repl_key] = repl_value }
            else
              hash[key] = value
            end

            hash
          end
        end
      end
    end
  end
end
