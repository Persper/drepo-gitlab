import * as types from './mutation_types';

export default {
  [types.REQUEST_SUGGESTIONS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_SUGGESTIONS_SUCCESS](state, suggestions) {
    state.isLoading = false;
    state.suggestions = suggestions;
  },
  [types.RECEIVE_SUGGESTIONS_ERROR](state) {
    state.isLoading = false;
  },
  [types.CLEAR_SUGGESTIONS](state) {
    state.suggestions = [];
  },
};
