<script>
import $ from 'jquery';
import noteEditedText from './note_edited_text.vue';
import noteAwardsList from './note_awards_list.vue';
import noteAttachment from './note_attachment.vue';
import noteForm from './note_form.vue';
import autosave from '../mixins/autosave';

export default {
  components: {
    noteEditedText,
    noteAwardsList,
    noteAttachment,
    noteForm,
  },
  mixins: [autosave],
  props: {
    note: {
      type: Object,
      required: true,
    },
    canEdit: {
      type: Boolean,
      required: true,
    },
    isEditing: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    noteBody() {
      return this.note.note;
    },
  },
  mounted() {
    this.renderGFM();

    if (this.isEditing) {
      this.initAutoSave(this.note);
    }
  },
  updated() {
    this.renderGFM();

    if (this.isEditing) {
      if (!this.autosave) {
        this.initAutoSave(this.note);
      } else {
        this.setAutoSave();
      }
    }
  },
  methods: {
    renderGFM() {
      $(this.$refs['note-body']).renderGFM();
    },
    handleFormUpdate(note, parentElement, callback) {
      this.$emit('handleFormUpdate', note, parentElement, callback);
    },
    formCancelHandler(shouldConfirm, isDirty) {
      this.$emit('cancelForm', shouldConfirm, isDirty);
    },
    mockSuggestion() {
      // temporary: this will be generated on the backend and returned in `note.note_html`
      return `
        <pre
        class="code js-render-suggestion white"
        data-comment="I suggest the following"
        data-file="test.html"
        ><code><span id="LC1" class="line">- &lt;p&gt;Foo&lt;/p&gt;</span>&#x000A;<span id="LC2" class="line">+ &lt;p&gt;Bar&lt;/p&gt;</span></code></pre>`;
    },
  },
};
</script>

<template>
  <div
    ref="note-body"
    :class="{ 'js-task-list-container': canEdit }"
    class="note-body">
    <div
      class="note-text md"
      v-html="mockSuggestion()"></div>
    <!--<div
      class="note-text md"
      v-html="note.note_html"></div>-->
    <note-form
      v-if="isEditing"
      ref="noteForm"
      :is-editing="isEditing"
      :note-body="noteBody"
      :note-id="note.id"
      :markdown-version="note.cached_markdown_version"
      @handleFormUpdate="handleFormUpdate"
      @cancelForm="formCancelHandler"
    />
    <textarea
      v-if="canEdit"
      v-model="note.note"
      :data-update-url="note.path"
      class="hidden js-task-list-field"></textarea>
    <note-edited-text
      v-if="note.last_edited_at"
      :edited-at="note.last_edited_at"
      :edited-by="note.last_edited_by"
      action-text="Edited"
      class="note_edited_ago"
    />
    <note-awards-list
      v-if="note.award_emoji && note.award_emoji.length"
      :note-id="note.id"
      :note-author-id="note.author.id"
      :awards="note.award_emoji"
      :toggle-award-path="note.toggle_award_path"
      :can-award-emoji="note.current_user.can_award_emoji"
    />
    <note-attachment
      v-if="note.attachment"
      :attachment="note.attachment"
    />
  </div>
</template>
