# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      module Build
        class Scheduled < Status::Extended
          def illustration
            {
              image: 'illustrations/illustrations_scheduled-job_countdown.svg',
              size: 'svg-394',
              title: _("This is a delayed job to run in %{remainingTime}"),
              content: _("This job will automatically run after it's timer finishes. " \
                         "Often they are used for incremental roll-out deploys " \
                         "to production environments. When unscheduled it converts " \
                         "into a manual action.")
            }
          end

          def status_tooltip
            "delayed manual action (%{remainingTime})"
          end

          def self.matches?(build, user)
            build.scheduled? && build.scheduled_at
          end
        end
      end
    end
  end
end
