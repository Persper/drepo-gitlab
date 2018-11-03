import { scrollToElement } from '~/lib/utils/common_utils';
import eventHub from '../../notes/event_hub';

export default {
  methods: {
    jumpToDiscussion(id) {
      if (id) {
        const activeTab = window.mrTabs.currentAction;
        const selector =
          activeTab === 'diffs'
            ? `ul.notes[data-discussion-id="${id}"]`
            : `div.discussion[data-discussion-id="${id}"]`;

        eventHub.$once('scrollToDiscussion', () => {
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

        this.expandDiscussion({ discussionId: id });
      }
    },
  },
};
