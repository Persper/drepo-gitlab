import Vue from 'vue';
import Vuex from 'vuex';
import state from './state';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';

Vue.use(Vuex);

export const createStore = () =>
  new Vuex.Store({
    state,
    actions,
    mutations,
    getters,
  });

export default createStore();
