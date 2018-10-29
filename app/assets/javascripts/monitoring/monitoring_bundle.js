import Vue from 'vue';
import { convertPermissionToBoolean } from '~/lib/utils/common_utils';
import Translate from '~/vue_shared/translate';
import Dashboard from './components/dashboard.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('prometheus-graphs');

  if (el && el.dataset) {
    // eslint-disable-next-line no-new
    new Vue({
      el,
      render(createElement) {
        return createElement(Dashboard, {
          props: {
            ...el.dataset,
            hasMetrics: convertPermissionToBoolean(el.dataset.hasMetrics),
          },
        });
      },
    });
  }
};
