import Vue from 'vue';
import JobContainerItem from '~/jobs/components/job_container_item.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import job from '../mock_data';

describe('JobContainerItem', () => {
  const Component = Vue.extend(JobContainerItem);
  let vm;

  afterEach(() => {
    vm.$destroy();
  });

  const sharedTests = () => {
    it('displays the job name', () => {
      const jobNameElement = vm.$el.querySelector('.js-job-name');

      expect(jobNameElement).not.toBe(null);
    });

    it('displays a link to the job', () => {
      const link = vm.$el.querySelector('.js-job-link');

      expect(link.href).toBe(job.status.details_path);
    });
  };

  describe('when a job is not active and not retied', () => {
    beforeEach(() => {
      vm = mountComponent(Component, {
        job,
        isActive: false,
      });
    });

    sharedTests();
  });

  describe('when a job is active', () => {
    beforeEach(() => {
      vm = mountComponent(Component, {
        job,
        isActive: true,
      });
    });

    sharedTests();

    it('displays an arrow', () => {
      expect(vm.$el).toHaveSpriteIcon('arrow-right');
    });
  });

  describe('when a job is retried', () => {
    beforeEach(() => {
      vm = mountComponent(Component, {
        job: {
          ...job,
          retried: true,
        },
        isActive: false,
      });
    });

    sharedTests();

    it('displays an icon', () => {
      expect(vm.$el).toHaveSpriteIcon('retry');
    });
  });
});
