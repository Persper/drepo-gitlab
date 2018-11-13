import Vue from 'vue';
import VueApollo from 'vue-apollo';
import ApolloClient from 'apollo-boost';
import App from './components/app.vue';
import csrf from '~/lib/utils/csrf';

Vue.use(VueApollo);

export default function() {
  const el = document.getElementById('js-suggestions');
  const issueTitle = document.getElementById('issue_title');
  const { projectPath } = el.dataset;
  const apolloProvider = new VueApollo({
    defaultClient: new ApolloClient({
      uri: '/api/graphql',
      headers: {
        [csrf.headerKey]: csrf.token,
      },
    }),
  });

  return new Vue({
    el,
    apolloProvider,
    data() {
      return {
        search: issueTitle.value,
      };
    },
    mounted() {
      issueTitle.addEventListener('input', () => {
        this.search = issueTitle.value;
      });
    },
    render(h) {
      return h(App, {
        props: {
          projectPath,
          search: this.search,
        },
      });
    },
  });
}
