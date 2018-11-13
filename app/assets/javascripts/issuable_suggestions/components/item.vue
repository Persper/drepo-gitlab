<script>
import { GlLink, GlTooltip, GlTooltipDirective } from '@gitlab-org/gitlab-ui';
import { __ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';
import TimeagoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import timeago from '~/vue_shared/mixins/timeago';

export default {
  components: {
    GlTooltip,
    GlLink,
    Icon,
    UserAvatarImage,
    TimeagoTooltip,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeago],
  props: {
    suggestion: {
      type: Object,
      required: true,
    },
  },
  computed: {
    isOpen() {
      return this.suggestion.state === 'opened';
    },
    isClosed() {
      return this.suggestion.state === 'closed';
    },
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
      return this.isClosed ? 'issue-close' : 'issue-open-m';
    },
    stateTitle() {
      return this.isClosed ? __('Closed') : __('Opened');
    },
    closedOrCreatedDate() {
      return this.suggestion.closedAt || this.suggestion.createdAt;
    },
  },
};
</script>

<template>
  <div class="suggestion-item">
    <div>
      <icon
        v-if="suggestion.confidential"
        v-gl-tooltip.bottom
        :title="__('Confidential')"
        name="eye-slash"
        class="suggestion-help-hover text-warning"
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
        ref="state"
        :name="stateIcon"
        :class="{
          'suggestion-state-open': isOpen,
          'suggestion-state-closed': isClosed
        }"
        class="suggestion-help-hover"
      />
      <gl-tooltip
        :target="() => $refs.state"
        placement="bottom"
      >
        <span class="d-block">
          <strong>
            {{ stateTitle }}
          </strong>
          <span class="bold">
            {{ timeFormated(closedOrCreatedDate) }}
          </span>
        </span>
        {{ tooltipTitle(closedOrCreatedDate) }}
      </gl-tooltip>
      #{{ suggestion.iid }}
      &middot;
      <timeago-tooltip
        :time="suggestion.createdAt"
        tooltip-placement="bottom"
        class="suggestion-help-hover"
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
          class="suggestion-help-hover"
        />
      </template>
      <span class="suggestion-counts">
        <span
          v-for="({ count, icon, tooltipTitle }, index) in counts"
          :key="index"
          v-gl-tooltip.bottom
          :title="tooltipTitle"
          class="suggestion-help-hover ml-2"
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

.suggestion-help-hover {
  cursor: help;
}
</style>
