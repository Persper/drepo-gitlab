<script>
import { mapState } from 'vuex';
import { GlLink } from '@gitlab-org/gitlab-ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
    GlLink,
  },
  computed: {
    ...mapState(['suggestions', 'isLoading']),
  },
};
</script>

<template>
  <div
    v-if="suggestions.length || isLoading"
    class="md-area prepend-top-default"
  >
    <template v-if="suggestions.length && !isLoading">
      <p class="bold">
        {{ __('Possible related issues') }}
      </p>
      <ul>
        <li
          v-for="suggestion in suggestions"
          :key="suggestion.id"
        >
          <gl-link
            :href="suggestion.web_url"
            target="_blank"
          >
            <span class="suggestion-title">
              #{{ suggestion.iid }}
              {{ suggestion.title }}
            </span>
            <span class="suggestion-counts">
              <span class="ml-2">
                <icon
                  name="thumb-up"
                />
                {{ suggestion.upvotes }}
              </span>
              <span class="ml-2">
                <icon
                  name="comment"
                />
                {{ suggestion.user_notes_count }}
              </span>
            </span>
          </gl-link>
        </li>
      </ul>
    </template>
    <p
      v-else-if="isLoading"
      class="bold mb-0"
    >
      {{ __('Searching for possible related issues') }}
      <i class="fa fa-spinner fa-spin"></i>
    </p>
  </div>
</template>

<style scoped>
ul {
  margin: 0;
  padding: 0;
}

ul li {
  display: flex;
  margin: 0 -6px 4px;
  padding: 0;
  list-style: none;
}

ul li a {
  display: flex;
  width: 100%;
  color: initial;
  padding: 4px 6px;
}

ul li a:hover,
ul li a:focus {
  background-color: #eee;
  text-decoration: none;
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
</style>
