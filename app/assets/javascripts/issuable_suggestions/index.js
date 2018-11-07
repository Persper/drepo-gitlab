import _ from 'underscore';
import Vue from 'vue';
import createStore from './store';
import App from './components/app.vue';

export default function() {
  const store = createStore();
  const el = document.getElementById('js-suggestions');
  const { projectId } = el.dataset;
  const onInput = _.debounce(
    e =>
      store.dispatch('fetchSuggestions', {
        projectId,
        search: e.target.value,
      }),
    500,
  );

  document.getElementById('issue_title').addEventListener('input', onInput);

  return new Vue({
    el,
    store,
    render(h) {
      return h(App);
    },
  });
}
