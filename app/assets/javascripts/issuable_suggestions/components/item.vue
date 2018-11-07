<script>
import { GlLink } from '@gitlab-org/gitlab-ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    GlLink,
    Icon,
  },
  props: {
    suggestion: {
      type: Object,
      required: true,
    },
  },
  computed: {
    counts() {
      return [
        {
          icon: 'thumb-up',
          count: this.suggestion.upvotes,
        },
        {
          icon: 'comment',
          count: this.suggestion.user_notes_count,
        },
      ];
    },
  },
};
</script>

<template>
  <gl-link
    v-once
    :href="suggestion.web_url"
    target="_blank"
    class="suggestion"
  >
    <span class="suggestion-title">
      #{{ suggestion.iid }}
      {{ suggestion.title }}
    </span>
    <span class="suggestion-counts">
      <span
        v-for="({ count, icon }, index) in counts"
        :key="index"
        :class="{
          faded: count === 0
        }"
        class="ml-2"
      >
        <icon
          :name="icon"
        />
        {{ count }}
      </span>
    </span>
  </gl-link>
</template>

<style>
.suggestion {
  display: flex;
  width: 100%;
  color: #2e2e2e;
  padding: 4px 6px;
  border-radius: 2px;
}

.suggestion:hover,
.suggestion:focus {
  color: #2e2e2e;
  background-color: #eee;
  text-decoration: none;
}

.suggestion svg {
  position: relative;
  top: 3px;
}

.suggestion-title {
  max-width: 100%;
  text-overflow: ellipsis;
  overflow: hidden;
  white-space: nowrap;
}

.suggestion-counts {
  display: flex;
  white-space: nowrap;
}

.faded {
  opacity: 0.4;
}
</style>
