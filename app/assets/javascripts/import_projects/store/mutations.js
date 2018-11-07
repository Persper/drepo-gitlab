import Vue from 'vue';
import * as types from './mutation_types';

export default {
  [types.SET_INITIAL_DATA](state, data) {
    Object.assign(state, data);
  },

  [types.REQUEST_REPOS](state) {
    Vue.set(state, 'isLoadingRepos', true);
    Vue.set(state, 'hasErrorRepos', false);
  },

  [types.RECEIVE_REPOS_SUCCESS](state, { importedProjects, providerRepos, namespaces }) {
    Vue.set(state, 'isLoadingRepos', false);
    Vue.set(state, 'hasErrorRepos', false);

    Vue.set(state, 'importedProjects', importedProjects);
    Vue.set(state, 'providerRepos', providerRepos);
    Vue.set(state, 'namespaces', namespaces);
  },

  [types.RECEIVE_REPOS_ERROR](state) {
    Vue.set(state, 'isLoadingRepos', false);
    Vue.set(state, 'hasErrorRepos', true);
  },

  [types.REQUEST_IMPORT](state, repoId) {
    if (!state.reposBeingImported.includes(repoId)) state.reposBeingImported.push(repoId);

    Vue.set(state, 'hasErrorImport', false);
  },

  [types.RECEIVE_IMPORT_SUCCESS](state, { importedProject, repoId }) {
    const existingRepoIndex = state.reposBeingImported.indexOf(repoId);
    if (existingRepoIndex > -1) state.reposBeingImported.splice(existingRepoIndex, 1);

    const providerRepoIndex = state.providerRepos.findIndex(
      providerRepo => providerRepo.id === repoId,
    );
    state.providerRepos.splice(providerRepoIndex, 1);
    state.importedProjects.unshift(importedProject);

    Vue.set(state, 'hasErrorImport', false);
  },

  [types.RECEIVE_IMPORT_ERROR](state) {
    Vue.set(state, 'hasErrorImport', true);
  },

  [types.REQUEST_JOBS](state) {
    Vue.set(state, 'hasErrorJobs', false);
  },

  [types.RECEIVE_JOBS_SUCCESS](state, updatedProjects) {
    Vue.set(state, 'hasErrorJobs', false);
    updatedProjects.forEach(updatedProject => {
      const existingProject = state.importedProjects.find(
        importedProject => importedProject.id === updatedProject.id,
      );

      Vue.set(existingProject, 'importStatus', updatedProject.importStatus);
    });
  },

  [types.RECEIVE_JOBS_ERROR](state) {
    Vue.set(state, 'hasErrorJobs', true);
  },
};
