import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import * as actions from '~/issuable_suggestions/store/actions';
import * as types from '~/issuable_suggestions/store/mutation_types';
import testAction from 'spec/helpers/vuex_action_helper';

describe('Issuable suggestions actions', () => {
  describe('requestSuggestions', () => {
    it('commits REQUEST_SUGGESTIONS', done => {
      testAction(
        actions.requestSuggestions,
        null,
        null,
        [{ type: types.REQUEST_SUGGESTIONS }],
        [],
        done,
      );
    });
  });

  describe('receiveSuggestionsSuccess', () => {
    it('commits RECEIVE_SUGGESTIONS_SUCCESS', done => {
      testAction(
        actions.receiveSuggestionsSuccess,
        'suggestions',
        null,
        [{ type: types.RECEIVE_SUGGESTIONS_SUCCESS, payload: 'suggestions' }],
        [],
        done,
      );
    });
  });

  describe('receiveSuggestionsError', () => {
    it('commits RECEIVE_SUGGESTIONS_ERROR', done => {
      testAction(
        actions.receiveSuggestionsError,
        null,
        null,
        [{ type: types.RECEIVE_SUGGESTIONS_ERROR }],
        [],
        done,
      );
    });
  });

  describe('fetchSuggestions', () => {
    let mock;
    let originalGon;
    let status;

    beforeAll(() => {
      const url = `/api/v4/projects/1/issues`;

      originalGon = window.gon;
      window.gon = Object.assign(
        {},
        {
          api_version: 'v4',
        },
      );

      mock = new MockAdapter(axios);
      mock.onGet(url).replyOnce(() => [
        status,
        {
          name: 'test',
        },
      ]);
    });

    afterAll(() => {
      mock.restore();
      window.gon = originalGon;
    });

    it('dispatches success actions for search', done => {
      status = 200;

      testAction(
        actions.fetchSuggestions,
        { projectId: '1', search: 'search' },
        null,
        [],
        [
          { type: 'requestSuggestions' },
          {
            type: 'receiveSuggestionsSuccess',
            payload: {
              name: 'test',
            },
          },
        ],
        done,
      );
    });

    it('dispatches error actions for search', done => {
      status = 500;

      testAction(
        actions.fetchSuggestions,
        { projectId: '1', search: 'search' },
        null,
        [],
        [{ type: 'requestSuggestions' }, { type: 'receiveSuggestionsError' }],
        done,
      );
    });
  });

  describe('clearSuggestions', () => {
    it('commits clearSuggestions', done => {
      testAction(
        actions.clearSuggestions,
        null,
        null,
        [{ type: types.CLEAR_SUGGESTIONS }],
        [],
        done,
      );
    });
  });
});
