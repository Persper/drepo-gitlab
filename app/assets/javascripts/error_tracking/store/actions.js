import Service from '../services';
import * as types from './mutation_types';
import createFlash from '~/flash';
import Poll from '~/lib/utils/poll';
import { __, sprintf } from '~/locale';

let eTagPoll;

export function startPolling({ commit }, endpoint) {
  eTagPoll = new Poll({
    resource: Service,
    method: 'getErrorList',
    data: { endpoint },
    successCallback: ({ data }) => {
      if (!data) {
        return;
      }
      commit(types.SET_ERRORS, data.errors);
      commit(types.SET_EXTERNAL_URL, data.external_url);
      commit(types.SET_LOADING, false);
    },
    errorCallback: response => {
      let errorMessage = '';
      if (response && response.data && response.data.message) {
        errorMessage = response.data.message;
      }
      commit(types.SET_LOADING, false);
      createFlash(
        sprintf(__(`Failed to load errors from Sentry. Error message: %{errorMessage}`), {
          errorMessage,
        }),
      );
    },
  });

  eTagPoll.makeRequest();
}

export default () => {};
