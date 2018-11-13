<script>
import { GlLoadingIcon, GlTooltipDirective } from '@gitlab-org/gitlab-ui';
import { __ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import Suggestion from './item.vue';
import issuesQuery from '../queries/issues.graphql';

export default {
  components: {
    GlLoadingIcon,
    Suggestion,
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
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
    },
  },
  methods: {
    hasIssues(data) {
      if (!data || !data.project) return false;

      return data.project.issues.length;
    },
  },
  issuesQuery,
  helpText: __(
    'These existing issues have a similar title. It might be better to comment there instead of creating another similar issue.',
  ),
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
    :debounce="250"
  >
    <div
      v-if="!isSearchEmpty && (loading || hasIssues(data))"
      slot-scope="{ result: { loading, data } }"
      class="form-group row issuable-suggestions"
    >
      <div
        v-once
        class="col-form-label col-sm-2 pt-0"
      >
        {{ __('Related Issues') }}
        <icon
          v-gl-tooltip.bottom
          :title="$options.helpText"
          name="question-o"
        />
      </div>
      <div class="col-sm-10">
        <p
          v-if="loading"
          class="bold mb-0 mt-0"
        >
          {{ __('Searching for possible related issues') }}
          <gl-loading-icon
            inline
          />
        </p>
        <ul
          v-else-if="hasIssues(data)"
          class="list-unstyled m-0"
        >
          <li
            v-for="(suggestion, index) in data.project.issues"
            :key="suggestion.id"
            :class="{
              'append-bottom-default': index !== data.project.issues.length - 1
            }"
          >
            <suggestion
              :suggestion="suggestion"
            />
          </li>
        </ul>
      </div>
    </div>
  </apollo-query>
</template>

<style>
.issuable-suggestions svg {
  vertical-align: sub;
}
</style>
