# frozen_string_literal: true

module QA
  module Page
    module Performance
      # Time taken to complete an action in page
      def response_time(callback)
        response_time = Benchmark.realtime do
          public_send(callback)
        end
        ( response_time * 1000 )
      end

      # Total Time taken to load page
      def page_load_time
        navigation_start = page.execute_script("return window.performance.timing.navigationStart")
        dom_complete = page.execute_script("return window.performance.timing.domComplete")
        dom_complete - navigation_start
      end

      # Time spent in the backend while loading the page
      def backend_response_time
        navigation_start = page.execute_script("return window.performance.timing.navigationStart")
        response_start = page.execute_script("return window.performance.timing.responseStart")
        response_start - navigation_start
      end

      # Time spent in the frontend while loading the page
      def frontend_load_time
        response_start = page.execute_script("return window.performance.timing.responseStart")
        dom_complete = page.execute_script("return window.performance.timing.domComplete")
        dom_complete - response_start
      end

      def apdex(samples_arr, response_threshold)
        satisfied_count = 0
        tolerating_count = 0
        samples_arr.each do |sample|
          if(sample <= response_threshold.to_f)
            satisfied_count += 1
          elsif(sample <= (4 * response_threshold.to_f))
            tolerating_count += 1
          end
        end
        (satisfied_count + (tolerating_count/2)) / samples_arr.length.to_f
      end
    end
  end
end
