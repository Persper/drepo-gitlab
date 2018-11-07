<script>
import { mapGetters, mapState } from 'vuex';
import { GlLoadingIcon } from '@gitlab-org/gitlab-ui';
import Suggestion from './item.vue';

export default {
  components: {
    GlLoadingIcon,
    Suggestion,
  },
  computed: {
    ...mapGetters(['showSuggestionsHolder', 'showSuggestions']),
    ...mapState(['suggestions', 'isLoading']),
  },
};
</script>

<template>
  <div
    v-if="showSuggestionsHolder"
    class="md-area prepend-top-default"
  >
    <div v-show="showSuggestions">
      <p class="bold mt-0">
        {{ __('Possible related issues') }}
      </p>
      <ul class="issuable-suggestion-list">
        <li
          v-for="suggestion in suggestions"
          :key="suggestion.id"
          class="issuable-suggestion-list-item"
        >
          <suggestion
            :suggestion="suggestion"
          />
        </li>
      </ul>
    </div>
    <p
      v-show="isLoading"
      class="bold mb-0 mt-0"
    >
      {{ __('Searching for possible related issues') }}
      <gl-loading-icon
        inline
      />
    </p>
  </div>
</template>

<style scoped>
.issuable-suggestion-list {
  margin: 0;
  padding: 0;
}

.issuable-suggestion-list-item {
  display: flex;
  margin: 0 -6px 4px;
  padding: 0;
  list-style: none;
}
</style>
