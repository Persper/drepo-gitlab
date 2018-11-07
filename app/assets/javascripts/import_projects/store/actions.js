import * as types from './mutation_types';
import axios from '../../lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '../../lib/utils/common_utils';
import simplePoll from '../../lib/utils/simple_poll';

export const setInitialData = ({ commit }, data) => commit(types.SET_INITIAL_DATA, data);

export const requestRepos = ({ commit }) => commit(types.REQUEST_REPOS);
export const receiveReposSuccess = ({ commit }, repos) =>
  commit(types.RECEIVE_REPOS_SUCCESS, repos);
export const receiveReposError = ({ commit }) => commit(types.RECEIVE_REPOS_ERROR);
export const fetchRepos = ({ state, dispatch }) => {
  dispatch('requestRepos');

  return axios
    .get(state.reposPath)
    .then(({ data }) =>
      dispatch('receiveReposSuccess', convertObjectPropsToCamelCase(data, { deep: true })),
    )
    .catch(() => dispatch('receiveReposError'));
};

export const requestImport = ({ commit }, repoId) => commit(types.REQUEST_IMPORT, repoId);
export const receiveImportSuccess = ({ commit }, { importedProject, repoId }) =>
  commit(types.RECEIVE_IMPORT_SUCCESS, { importedProject, repoId });
export const receiveImportError = ({ commit }) => commit(types.RECEIVE_IMPORT_ERROR);
export const fetchImport = ({ state, dispatch }, { newName, targetNamespace, repo }) => {
  dispatch('requestImport', repo.id);

  return axios
    .post(state.importPath, {
      ci_cd_only: state.ciCdOnly,
      new_name: newName,
      repo_id: repo.id,
      target_namespace: targetNamespace,
    })
    .then(({ data }) =>
      dispatch('receiveImportSuccess', {
        importedProject: convertObjectPropsToCamelCase(data, { deep: true }),
        repoId: repo.id,
      }),
    )
    .catch(() => dispatch('receiveImportError'));
};

export const requestJobs = ({ commit }) => commit(types.REQUEST_JOBS);
export const receiveJobsSuccess = ({ commit }, updatedProjects) =>
  commit(types.RECEIVE_JOBS_SUCCESS, updatedProjects);
export const receiveJobsError = ({ commit }) => commit(types.RECEIVE_JOBS_ERROR);
export const fetchJobs = ({ state, dispatch }) => {
  dispatch('requestJobs');

  return axios
    .get(state.jobsPath)
    .then(({ data }) =>
      dispatch('receiveJobsSuccess', convertObjectPropsToCamelCase(data, { deep: true })),
    )
    .catch(() => dispatch('receiveJobsError'));
};

export const pollJobs = ({ dispatch }) =>
  simplePoll(
    continuePolling => dispatch('fetchJobs').then(() => continuePolling()),
    3000,
    Infinity,
  );

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
