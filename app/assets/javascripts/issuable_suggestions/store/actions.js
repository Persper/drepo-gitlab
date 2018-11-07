import api from '~/api';
import * as types from './mutation_types';

export const requestSuggestions = ({ commit }) => commit(types.REQUEST_SUGGESTIONS);
export const receiveSuggestionsSuccess = ({ commit }, suggestions) =>
  commit(types.RECEIVE_SUGGESTIONS_SUCCESS, suggestions);
export const receiveSuggestionsError = ({ commit }) => commit(types.RECEIVE_SUGGESTIONS_ERROR);

export const fetchSuggestions = ({ dispatch }, { projectId, search }) => {
  if (search.trim() === '') return dispatch('clearSuggestions');

  dispatch('requestSuggestions');

  return api
    .getIssues(projectId, { search, per_page: '5' })
    .then(({ data }) => dispatch('receiveSuggestionsSuccess', data))
    .catch(() => dispatch('receiveSuggestionsError'));
};

export const clearSuggestions = ({ commit }) => commit(types.CLEAR_SUGGESTIONS);
