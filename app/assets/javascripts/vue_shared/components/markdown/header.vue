<script>
import $ from 'jquery';
import { GlTooltipDirective } from '@gitlab-org/gitlab-ui';
import ToolbarButton from './toolbar_button.vue';
import Icon from '../icon.vue';

export default {
  components: {
    ToolbarButton,
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    mode: {
      type: String,
      required: true,
    },
  },
  computed: {
    mdTable() {
      return [
        '| header | header |',
        '| ------ | ------ |',
        '| cell | cell |',
        '| cell | cell |',
      ].join('\n');
    },
  },
  mounted() {
    $(document).on('markdown-preview:show.vue', this.previewTab);
    $(document).on('markdown-preview:hide.vue', this.markdownTab);
  },
  beforeDestroy() {
    $(document).off('markdown-preview:show.vue', this.previewTab);
    $(document).off('markdown-preview:hide.vue', this.markdownTab);
  },
  methods: {
    isValid(form) {
      return !form ||
        form.find('.js-vue-markdown-field').length &&
        $(this.$el).closest('form')[0] === form[0];
    },

    previewTab(event, form) {
      if (event.target.blur) event.target.blur();
      if (!this.isValid(form)) return;

      this.$emit('preview');
    },

    markdownTab(event, form) {
      if (event.target.blur) event.target.blur();
      if (!this.isValid(form)) return;

      this.$emit('markdown');
    },

    richTab(event, form) {
      if (event.target.blur) event.target.blur();
      if (!this.isValid(form)) return;

      this.$emit('rich');
    },

    toolbarButtonClicked(button) {
      this.$emit('toolbarButtonClicked', button);
    }
  },
};
</script>

<template>
  <div class="md-header">
    <ul class="nav-links clearfix">
      <li
        :class="{ active: mode == 'markdown' }"
        class="md-header-tab"
      >
        <button
          class="js-write-link"
          tabindex="-1"
          type="button"
          @click="markdownTab($event)"
        >
          Markdown
        </button>
      </li>
      <li
        :class="{ active: mode == 'rich' }"
        class="md-header-tab"
      >
        <button
          class="js-rich-link"
          tabindex="-1"
          type="button"
          @click="richTab($event)"
        >
          Rich
        </button>
      </li>
      <li
        :class="{ active: mode == 'preview' }"
        class="md-header-tab"
      >
        <button
          class="js-preview-link"
          tabindex="-1"
          type="button"
          @click="previewTab($event)"
        >
          Preview
        </button>
      </li>
      <li
        :class="{ active: mode != 'preview' }"
        class="md-header-toolbar"
      >
        <toolbar-button
          @click="toolbarButtonClicked"
          tag="**"
          button-title="Add bold text"
          icon="bold"
        />
        <toolbar-button
          @click="toolbarButtonClicked"
          tag="*"
          button-title="Add italic text"
          icon="italic"
        />
        <toolbar-button
          @click="toolbarButtonClicked"
          :prepend="true"
          tag="> "
          button-title="Insert a quote"
          icon="quote"
        />
        <toolbar-button
          @click="toolbarButtonClicked"
          tag="`"
          tag-block="```"
          button-title="Insert code"
          icon="code"
        />
        <toolbar-button
          v-if="mode == 'markdown'"
          @click="toolbarButtonClicked"
          tag="[{text}](url)"
          tag-select="url"
          button-title="Add a link"
          icon="link"
        />
        <toolbar-button
          @click="toolbarButtonClicked"
          :prepend="true"
          tag="* "
          button-title="Add a bullet list"
          icon="list-bulleted"
        />
        <toolbar-button
          @click="toolbarButtonClicked"
          :prepend="true"
          tag="1. "
          button-title="Add a numbered list"
          icon="list-numbered"
        />
        <toolbar-button
          v-if="mode == 'markdown'"
          @click="toolbarButtonClicked"
          :prepend="true"
          tag="* [ ] "
          button-title="Add a task list"
          icon="task-done"
        />
        <toolbar-button
          v-if="mode == 'markdown'"
          :tag="mdTable"
          :prepend="true"
          :button-title="__('Add a table')"
          icon="table"
        />
        <button
          v-if="mode == 'markdown'"
          v-gl-tooltip
          aria-label="Go full screen"
          class="toolbar-btn toolbar-fullscreen-btn js-zen-enter"
          data-container="body"
          tabindex="-1"
          title="Go full screen"
          type="button"
        >
          <icon
            name="screen-full"
          />
        </button>
      </li>
    </ul>
  </div>
</template>
