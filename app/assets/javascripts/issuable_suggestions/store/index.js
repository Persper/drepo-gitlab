import Vue from 'vue';
import Vuex from 'vuex';
import * as actions from './actions';
import createState from './state';
import mutations from './mutations';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    actions,
    state: createState(),
    mutations,
  });
