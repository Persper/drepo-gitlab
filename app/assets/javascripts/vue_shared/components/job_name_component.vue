<script>
import CiIcon from './ci_icon.vue';

/**
 * Component that renders both the CI icon status and the job name.
 * Used in
 *  - Badge component
 *  - Dropdown badge components
 */
export default {
  components: {
    CiIcon,
  },
  props: {
    name: {
      type: String,
      required: true,
    },

    status: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <span class="ci-job-name-component">
    <ci-icon :status="status" />

    <span class="ci-status-text">
      {{ name }}
    </span>
  </span>
</template>
