import mutations from '~/issuable_suggestions/store/mutations';
import * as types from '~/issuable_suggestions/store/mutation_types';
import createState from '~/issuable_suggestions/store/state';

describe('Issuable suggestions mutatons', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe(types.REQUEST_SUGGESTIONS, () => {
    it('sets isLoading', () => {
      mutations[types.REQUEST_SUGGESTIONS](state);

      expect(state.isLoading).toBe(true);
    });
  });

  describe(types.RECEIVE_SUGGESTIONS_SUCCESS, () => {
    it('sets isLoading and suggestions', () => {
      mutations[types.RECEIVE_SUGGESTIONS_SUCCESS](state, 'suggestions');

      expect(state.isLoading).toBe(false);
      expect(state.suggestions).toBe('suggestions');
    });
  });

  describe(types.RECEIVE_SUGGESTIONS_ERROR, () => {
    it('sets isLoading', () => {
      mutations[types.RECEIVE_SUGGESTIONS_ERROR](state);

      expect(state.isLoading).toBe(false);
    });
  });

  describe(types.CLEAR_SUGGESTIONS, () => {
    it('sets suggestions to empty array', () => {
      state.suggestions = ['suggestion'];

      mutations[types.CLEAR_SUGGESTIONS](state);

      expect(state.suggestions).toEqual([]);
    });
  });
});
