import { scrollToElement } from '~/lib/utils/common_utils';

export default {
  methods: {
    jumpToDiscussion(id) {
      if (id) {
        const activeTab = window.mrTabs.currentAction;
        const selector =
          activeTab === 'diffs'
            ? `ul.notes[data-discussion-id="${id}"]`
            : `div.discussion[data-discussion-id="${id}"]`;

        this.expandDiscussion({ discussionId: id });

        this.$nextTick(() => {
          const el = document.querySelector(selector);

          if (activeTab === 'commits' || activeTab === 'pipelines') {
            window.mrTabs.activateTab('show');
          }

          if (el) {
            scrollToElement(el);

            return true;
          }

          return false;
        });
      }
    },
  },
};
