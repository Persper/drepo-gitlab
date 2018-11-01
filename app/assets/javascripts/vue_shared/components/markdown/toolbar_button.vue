<script>
import { GlTooltipDirective } from '@gitlab-org/gitlab-ui';
import Icon from '../icon.vue';

export default {
  components: {
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    buttonTitle: {
      type: String,
      required: true,
    },
    icon: {
      type: String,
      required: true,
    },
    tag: {
      type: String,
      required: true,
    },
    tagBlock: {
      type: String,
      required: false,
      default: '',
    },
    tagSelect: {
      type: String,
      required: false,
      default: '',
    },
    prepend: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    clicked() {
      this.$emit('click', this);
    },
  },
};
</script>

<template>
  <button
    v-gl-tooltip
    :title="buttonTitle"
    :aria-label="buttonTitle"
    type="button"
    class="toolbar-btn"
    tabindex="-1"
    data-container="body"
    @click="clicked"
  >
    <icon
      :name="icon"
    />
  </button>
</template>
