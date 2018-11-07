<script>
import CiIcon from '../../vue_shared/components/ci_icon.vue';
import STATUS_MAP, { STATUSES } from '../constants';

export default {
  name: 'ImportedProjectTableRow',

  components: {
    CiIcon,
  },

  props: {
    project: {
      type: Object,
      required: true,
    },
  },

  computed: {
    statusObject() {
      return STATUS_MAP[this.project.importStatus];
    },

    ciIconStatus() {
      const { icon } = this.statusObject;

      return {
        icon: `status_${icon}`,
        group: icon,
      };
    },

    statusText() {
      return this.statusObject.text;
    },

    statusTextClass() {
      return this.statusObject.textClass;
    },

    displayFullPath() {
      return this.project.fullPath.replace(/^\//, '');
    },

    isFinished() {
      return this.project.importStatus === STATUSES.FINISHED;
    },
  },
};
</script>

<template>
  <tr>
    <td>
      <a
        :href="project.providerLink"
        rel="noreferrer noopener"
        target="_blank"
      >
        {{ project.importSource }}
      </a>
    </td>
    <td>
      {{ displayFullPath }}
    </td>
    <td>
      <ci-icon
        css-classes="align-middle mr-2"
        :status="ciIconStatus"
      />
      <span :class="statusTextClass">{{ statusText }}</span>
    </td>
    <td>
      <a
        v-if="isFinished"
        class="btn btn-default"
        :href="project.fullPath"
        rel="noreferrer noopener"
        target="_blank"
      >
        {{ __('Go to project') }}
      </a>
    </td>
  </tr>
</template>
