<script>
import { GlLoadingIcon } from '@gitlab-org/gitlab-ui';
import Suggestion from './item.vue';
import issuesQuery from '../queries/issues';

export default {
  components: {
    GlLoadingIcon,
    Suggestion,
  },
  props: {
    projectPath: {
      type: String,
      required: true,
    },
    search: {
      type: String,
      required: true,
    },
  },
  computed: {
    isSearchEmpty() {
      return this.search.trim() === '';
    }
  },
  methods: {
    hasIssues(data) {
      if (!data || !data.project) return false;

      return data.project.issues.length;
    },
  },
  issuesQuery,
};
</script>

<template>
  <apollo-query
    :query="$options.issuesQuery"
    :variables="{
      fullPath: projectPath,
      search
    }"
    :skip="isSearchEmpty"
  >
    <template slot-scope="{ result: { loading, error, data } }">
      <div
        v-if="!isSearchEmpty && (loading || hasIssues(data))"
        class="md-area prepend-top-default"
      >
        <p
          v-if="loading"
          class="bold mb-0 mt-0"
        >
          {{ __('Searching for possible related issues') }}
          <gl-loading-icon
            inline
          />
        </p>
        <div v-else-if="hasIssues(data)">
          <p class="bold mt-0">
            {{ __('Possible related issues') }}
          </p>
          <ul class="issuable-suggestion-list">
            <li
              v-for="suggestion in data.project.issues"
              :key="suggestion.id"
              class="issuable-suggestion-list-item"
            >
              <suggestion
                :suggestion="suggestion"
              />
            </li>
          </ul>
        </div>
      </div>
    </template>
  </apollo-query>
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

.issuable-suggestion-list-item:last-child {
  margin-bottom: 0;
}
</style>
