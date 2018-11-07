import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import {
  SET_INITIAL_DATA,
  REQUEST_REPOS,
  RECEIVE_REPOS_SUCCESS,
  RECEIVE_REPOS_ERROR,
  REQUEST_IMPORT,
  RECEIVE_IMPORT_SUCCESS,
  RECEIVE_IMPORT_ERROR,
  REQUEST_JOBS,
} from '~/import_projects/store/mutation_types';
import {
  setInitialData,
  requestRepos,
  receiveReposSuccess,
  receiveReposError,
  fetchRepos,
  requestImport,
  receiveImportSuccess,
  receiveImportError,
  fetchImport,
  requestJobs,
} from '~/import_projects/store/actions';
import state from '~/import_projects/store/state';
import testAction from 'spec/helpers/vuex_action_helper';
import { TEST_HOST } from 'spec/test_constants';

describe('import_projects store actions', () => {
  let localState;

  beforeEach(() => {
    localState = state();
  });

  describe('setInitialData', () => {
    it(`commits ${SET_INITIAL_DATA} mutation`, done => {
      const initialData = {
        reposPath: 'reposPath',
        provider: 'provider',
        jobsPath: 'jobsPath',
        importPath: 'importPath',
        currentUserNamespace: 'currentUserNamespace',
        ciCdOnly: 'ciCdOnly',
        canSelectNamespace: 'canSelectNamespace',
      };

      testAction(
        setInitialData,
        initialData,
        localState,
        [{ type: SET_INITIAL_DATA, payload: initialData }],
        [],
        done,
      );
    });
  });

  describe('requestRepos', () => {
    it(`requestRepos commits ${REQUEST_REPOS} mutation`, done => {
      testAction(requestRepos, null, localState, [{ type: REQUEST_REPOS }], [], done);
    });
  });

  describe('receiveReposSuccess', () => {
    it(`commits ${RECEIVE_REPOS_SUCCESS} mutation`, done => {
      const repos = new Array(2);

      testAction(
        receiveReposSuccess,
        repos,
        localState,
        [{ type: RECEIVE_REPOS_SUCCESS, payload: repos }],
        [],
        done,
      );
    });
  });

  describe('receiveReposError', () => {
    it(`commits ${RECEIVE_REPOS_ERROR} mutation`, done => {
      const repos = new Array(2);

      testAction(receiveReposError, repos, localState, [{ type: RECEIVE_REPOS_ERROR }], [], done);
    });
  });

  describe('fetchRepos', () => {
    let mock;

    beforeEach(() => {
      localState.reposPath = `${TEST_HOST}/endpoint.json`;
      mock = new MockAdapter(axios);
    });

    afterEach(() => mock.restore());

    it('dispatches requestRepos and receiveReposSuccess actions on a successful request', done => {
      const payload = { imported_projects: [{}], provider_repos: [{}], namespaces: [{}] };
      mock.onGet(`${TEST_HOST}/endpoint.json`).reply(200, payload);

      testAction(
        fetchRepos,
        null,
        localState,
        [],
        [
          { type: 'requestRepos' },
          {
            type: 'receiveReposSuccess',
            payload: convertObjectPropsToCamelCase(payload, { deep: true }),
          },
        ],
        done,
      );
    });

    it('dispatches requestRepos and receiveReposSuccess actions on an unsuccessful request', done => {
      mock.onGet(`${TEST_HOST}/endpoint.json`).reply(500);

      testAction(
        fetchRepos,
        null,
        localState,
        [],
        [{ type: 'requestRepos' }, { type: 'receiveReposError' }],
        done,
      );
    });
  });

  describe('requestImport', () => {
    it(`commits ${REQUEST_IMPORT} mutation`, done => {
      const repoId = 1;

      testAction(
        requestImport,
        repoId,
        localState,
        [{ type: REQUEST_IMPORT, payload: repoId }],
        [],
        done,
      );
    });
  });

  describe('receiveImportSuccess', () => {
    it(`commits ${RECEIVE_IMPORT_SUCCESS} mutation`, done => {
      const payload = { importedProject: { name: 'imported/project' }, repoId: 2 };

      testAction(
        receiveImportSuccess,
        payload,
        localState,
        [{ type: RECEIVE_IMPORT_SUCCESS, payload }],
        [],
        done,
      );
    });
  });

  describe('receiveImportError', () => {
    it(`commits ${RECEIVE_IMPORT_ERROR} mutation`, done => {
      testAction(receiveImportError, null, localState, [{ type: RECEIVE_IMPORT_ERROR }], [], done);
    });
  });

  describe('fetchImport', () => {
    let mock;

    beforeEach(() => {
      localState.importPath = `${TEST_HOST}/endpoint.json`;
      mock = new MockAdapter(axios);
    });

    afterEach(() => mock.restore());

    it('dispatches requestImport and receiveImportSuccess actions on a successful request', done => {
      const importedProject = { name: 'imported/project' };
      const payload = { newName: 'newName', targetNamespace: 'targetNamespace', repo: { id: 1 } };
      const repoId = payload.repo.id;
      mock.onPost(`${TEST_HOST}/endpoint.json`).reply(200, importedProject);

      testAction(
        fetchImport,
        payload,
        localState,
        [],
        [
          { type: 'requestImport', payload: repoId },
          {
            type: 'receiveImportSuccess',
            payload: {
              importedProject: convertObjectPropsToCamelCase(importedProject, { deep: true }),
              repoId,
            },
          },
        ],
        done,
      );
    });

    it('dispatches requestImport and receiveImportSuccess actions on an unsuccessful request', done => {
      const payload = { newName: 'newName', targetNamespace: 'targetNamespace', repo: { id: 1 } };
      mock.onPost(`${TEST_HOST}/endpoint.json`).reply(500);

      testAction(
        fetchImport,
        payload,
        localState,
        [],
        [{ type: 'requestImport', payload: payload.repo.id }, { type: 'receiveImportError' }],
        done,
      );
    });
  });

  describe('requestJobs', () => {
    it(`commits ${REQUEST_JOBS} mutation`, done => {
      testAction(requestJobs, null, localState, [{ type: REQUEST_JOBS }], [], done);
    });
  });
});
