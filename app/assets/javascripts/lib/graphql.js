import ApolloClient from 'apollo-boost';
import csrf from '~/lib/utils/csrf';

export default new ApolloClient({
  uri: `${gon.gitlab_url || ''}/api/graphql`,
  headers: {
    [csrf.headerKey]: csrf.token,
  },
});
