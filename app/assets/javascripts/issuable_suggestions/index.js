import _ from 'underscore';
import Vue from 'vue';
import { mapActions } from 'vuex';
import createStore from './store';
import App from './components/app.vue';

export default function() {
  const store = createStore();
  const el = document.getElementById('js-suggestions');
  const issueTitle = document.getElementById('issue_title');
  const { projectId } = el.dataset;

  return new Vue({
    el,
    store,
    mounted() {
      this.sendSearchRequest();

      issueTitle.addEventListener('input', this.search);
    },
    methods: {
      ...mapActions(['fetchSuggestions']),
      sendSearchRequest() {
        this.fetchSuggestions({
          projectId,
          search: issueTitle.value,
        });
      },
      search: _.debounce(function searchDebouned(e) {
        this.sendSearchRequest(e.target.value);
      }, 250),
    },
    render(h) {
      return h(App);
    },
  });
}
