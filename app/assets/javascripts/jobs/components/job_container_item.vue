<script>
import _ from 'underscore';
import CiIcon from '~/vue_shared/components/ci_icon.vue';
import Icon from '~/vue_shared/components/icon.vue';
import JobName from '~/vue_shared/components/job_name_component.vue';
import tooltip from '~/vue_shared/directives/tooltip';

export default {
  components: {
    CiIcon,
    Icon,
    JobName,
  },

  directives: {
    tooltip,
  },

  props: {
    job: {
      type: Object,
      required: true,
    },
    isActive: {
      type: Boolean,
      required: true,
    },
  },

  computed: {
    jobName() {
      return this.job.name ? this.job.name : this.job.id.toString();
    },

    tooltipText() {
      return `${_.escape(this.job.name)} - ${this.job.status.tooltip}`;
    },
  },
};
</script>

<template>
  <div
    class="build-job"
    :class="{ retried: job.retried, active: isActive }"
  >
    <a
      v-tooltip
      :href="job.status.details_path"
      :title="tooltipText"
      data-container="body"
      data-boundary="viewport"
      class="js-job-link"
    >
      <icon
        v-if="isActive"
        name="arrow-right"
        class="js-arrow-right icon-arrow-right"
      />

      <job-name
        class="js-job-name"
        :name="jobName"
        :status="job.status"
      />

      <icon
        v-if="job.retried"
        name="retry"
        class="js-retry-icon"
      />
    </a>
  </div>
</template>
