<script>
import $ from 'jquery';

export default {
  props: {
    suggestion: {
      type: String,
      required: true,
    },
    fileName: {
      type: String,
      required: false,
      default: '',
    },
    canApply: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    suggestionComment() {
      const suggestionHtml = $.parseHTML(this.mockSuggestion)[1];
      return suggestionHtml.dataset.comment;
    },
    mockSuggestion() {
      // temporary: this will be generated on the backend and returned via api call in parent
      return `
        <pre class="code js-render-suggestion white" data-comment="I suggest the following"><code><span id="LC1" class="line">- &lt;p&gt;Foo&lt;/p&gt;</span>&#x000A;<span id="LC2" class="line">+ &lt;p&gt;Bar&lt;/p&gt;</span></code></pre>`;
    },
  },
  methods: {
    applySuggestion() {
      // TODO dispatch > api call
    },
  },
};
</script>

<template>
  <div>
    {{ suggestionComment }}
    <div class="file-title-flex-parent md-suggestion-header border-bottom-0 mt-2">
      {{ fileName }}
      <button
        v-if="canApply"
        type="button"
        class="btn"
        @click="applySuggestion">Apply</button>
    </div>
    <div
      v-html="mockSuggestion">
    </div>
  </div>
</template>
