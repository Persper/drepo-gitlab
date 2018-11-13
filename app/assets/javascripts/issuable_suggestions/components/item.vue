<script>
import { GlLink, GlTooltipDirective } from '@gitlab-org/gitlab-ui';
import Icon from '~/vue_shared/components/icon.vue';
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';
import TimeagoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    GlLink,
    Icon,
    UserAvatarImage,
    TimeagoTooltip,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
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
          tooltipTitle: 'Upvotes',
          count: this.suggestion.upvotes,
        },
        {
          icon: 'comment',
          tooltipTitle: 'Comments',
          count: this.suggestion.userNotesCount,
        },
      ].filter(({ count }) => count);
    },
    stateIcon() {
      return this.suggestion.state === 'closed' ? 'issue-close' : 'issue-open-m';
    },
  },
};
</script>

<template>
  <div class="suggestion-item">
    <div>
      <icon
        v-if="suggestion.confidential"
        name="eye-slash"
        class="text-warning"
      />
      <gl-link
        :href="suggestion.webUrl"
        target="_blank"
        class="suggestion bold"
      >
        {{ suggestion.title }}
      </gl-link>
    </div>
    <div class="text-secondary">
      <icon
        :name="stateIcon"
        :class="{
          'suggestion-state-open': suggestion.state === 'opened',
          'suggestion-state-closed': suggestion.state === 'closed'
        }"
      />
      #{{ suggestion.iid }}
      &middot;
      <timeago-tooltip
        :time="suggestion.createdAt"
        tooltip-placement="bottom"
      />
      by
      <gl-link
        :href="suggestion.author.webUrl"
      >
        <user-avatar-image
          :img-src="suggestion.author.avatarUrl"
          :size="16"
          css-classes="mr-0 float-none"
          tooltip-placement="bottom"
          class="d-inline-block"
        >
          <strong class="d-block">Author</strong>
          <span class="bold">{{ suggestion.author.name }}</span> @{{ suggestion.author.username }}
        </user-avatar-image>
      </gl-link>
      <template v-if="suggestion.updatedAt !== suggestion.createdAt">
        &middot;
        updated
        <timeago-tooltip
          :time="suggestion.updatedAt"
          tooltip-placement="bottom"
        />
      </template>
      <span class="suggestion-counts">
        <span
          v-for="({ count, icon, tooltipTitle }, index) in counts"
          :key="index"
          v-gl-tooltip.bottom
          :title="tooltipTitle"
          class="ml-2"
        >
          <icon
            :name="icon"
          />
          {{ count }}
        </span>
      </span>
    </div>
  </div>
</template>

<style>
.suggestion-item a {
  color: initial;
}

.suggestion-state-open {
  color: #1aaa55;
}

.suggestion-state-closed {
  color: #1f78d1;
}

.suggestion-counts span {
  cursor: help;
}
</style>
