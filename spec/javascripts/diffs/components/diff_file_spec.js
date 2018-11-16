import Vue from 'vue';
import DiffFileComponent from '~/diffs/components/diff_file.vue';
import store from '~/mr_notes/stores';
import { createComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import diffFileMockData from '../mock_data/diff_file';

describe('DiffFile', () => {
  let vm;

  beforeEach(() => {
    vm = createComponentWithStore(Vue.extend(DiffFileComponent), store, {
      file: JSON.parse(JSON.stringify(diffFileMockData)),
      canCurrentUserFork: false,
    }).$mount();
  });

  describe('template', () => {
    it('should render component with file header, file content components', () => {
      const el = vm.$el;
      const { file_hash, file_path } = vm.file;

      expect(el.id).toEqual(file_hash);
      expect(el.classList.contains('diff-file')).toEqual(true);

      expect(el.querySelectorAll('.diff-content.hidden').length).toEqual(0);
      expect(el.querySelector('.js-file-title')).toBeDefined();
      expect(el.querySelector('.file-title-name').innerText.indexOf(file_path)).toBeGreaterThan(-1);
      expect(el.querySelector('.js-syntax-highlight')).toBeDefined();

      expect(vm.file.renderIt).toEqual(false);
      vm.file.renderIt = true;

      vm.$nextTick(() => {
        expect(el.querySelectorAll('.line_content').length).toBeGreaterThan(5);
      });
    });

    describe('collapsed', () => {
      it('should not have file content', done => {
        expect(vm.$el.querySelectorAll('.diff-content').length).toEqual(1);
        expect(vm.file.collapsed).toEqual(false);
        vm.file.collapsed = true;
        vm.file.renderIt = true;

        vm.$nextTick(() => {
          expect(vm.$el.querySelectorAll('.diff-content').length).toEqual(0);

          done();
        });
      });

      it('should have collapsed text and link', done => {
        vm.file.renderIt = true;
        vm.file.collapsed = false;
        vm.file.highlighted_diff_lines = null;

        vm.$nextTick(() => {
          expect(vm.$el.innerText).toContain('This diff is collapsed');
          expect(vm.$el.querySelectorAll('.js-click-to-expand').length).toEqual(1);

          done();
        });
      });

      it('should have collapsed text and link even before rendered', done => {
        vm.file.renderIt = false;
        vm.file.collapsed = true;

        vm.$nextTick(() => {
          expect(vm.$el.innerText).toContain('This diff is collapsed');
          expect(vm.$el.querySelectorAll('.js-click-to-expand').length).toEqual(1);

          done();
        });
      });

      it('should have loading icon while loading a collapsed diffs', done => {
        vm.file.collapsed = true;
        vm.isLoadingCollapsedDiff = true;

        vm.$nextTick(() => {
          expect(vm.$el.querySelectorAll('.diff-content.loading').length).toEqual(1);

          done();
        });
      });
    });
  });

  describe('too large diff', () => {
    it('should have too large warning and blob link', done => {
      const BLOB_LINK = '/file/view/path';
      vm.file.too_large = true;
      vm.file.view_path = BLOB_LINK;

      vm.$nextTick(() => {
        expect(vm.$el.innerText).toContain(
          'This source diff could not be displayed because it is too large',
        );

        expect(vm.$el.querySelector('.js-too-large-diff')).toBeDefined();
        expect(
          vm.$el.querySelector('.js-too-large-diff a').href.indexOf(BLOB_LINK),
        ).toBeGreaterThan(-1);

        done();
      });
    });
  });

  describe('watch collapsed', () => {
    it('calls handleLoadCollapsedDiff if collapsed changed & file has no lines', done => {
      spyOn(vm, 'handleLoadCollapsedDiff');

      vm.file.highlighted_diff_lines = undefined;
      vm.file.parallel_diff_lines = [];
      vm.file.collapsed = true;

      vm.$nextTick()
        .then(() => {
          vm.file.collapsed = false;

          return vm.$nextTick();
        })
        .then(() => {
          expect(vm.handleLoadCollapsedDiff).toHaveBeenCalled();
        })
        .then(done)
        .catch(done.fail);
    });
  });
});
