import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import App from '~/issuable_suggestions/components/app.vue';
import Suggestion from '~/issuable_suggestions/components/item.vue';
import defaultClient from '~/lib/graphql';

describe('Issuable suggestions app component', () => {
  const apolloProvider = new VueApollo({
    defaultClient,
  });
  let localVue;
  let vm;

  function createComponent(search = 'search') {
    vm = shallowMount(App, {
      localVue,
      provide: apolloProvider,
      propsData: {
        search,
        projectPath: 'project',
      },
    });
  }

  beforeEach(() => {
    localVue = createLocalVue();

    localVue.use(VueApollo);
  });

  it('does not render with empty search', () => {
    createComponent('');

    expect(vm.isEmpty()).toBe(true);
  });

  describe('with data', () => {
    let data;

    beforeEach(() => {
      data = { issues: [{ id: 1 }, { id: 2 }] };
    });

    it('renders component', () => {
      createComponent();
      vm.setData(data);

      expect(vm.isEmpty()).toBe(false);
    });

    it('does not render with empty search', () => {
      createComponent('');
      vm.setData(data);

      expect(vm.isEmpty()).toBe(true);
    });

    it('does not render with empty issues data', () => {
      createComponent();
      vm.setData({ issues: [] });

      expect(vm.isEmpty()).toBe(true);
    });

    it('renders list of issues', () => {
      createComponent();
      vm.setData(data);

      expect(vm.findAll(Suggestion).length).toBe(2);
    });

    it('adds margin class to first item', () => {
      createComponent();
      vm.setData(data);

      expect(
        vm
          .findAll('li')
          .at(0)
          .is('.append-bottom-default'),
      ).toBe(true);
    });

    it('does not add margin class to last item', () => {
      createComponent();
      vm.setData(data);

      expect(
        vm
          .findAll('li')
          .at(1)
          .is('.append-bottom-default'),
      ).toBe(false);
    });
  });
});
