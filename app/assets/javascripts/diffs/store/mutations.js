import Vue from 'vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { sortTree } from '~/ide/stores/utils';
import {
  findDiffFile,
  addLineReferences,
  removeMatchLine,
  addContextLines,
  prepareDiffData,
  isDiscussionApplicableToLine,
  generateTreeList,
} from './utils';
import * as types from './mutation_types';

export default {
  [types.SET_BASE_CONFIG](state, options) {
    const { endpoint, projectPath } = options;
    Object.assign(state, { endpoint, projectPath });
  },

  [types.SET_LOADING](state, isLoading) {
    Object.assign(state, { isLoading });
  },

  [types.SET_DIFF_DATA](state, data) {
    prepareDiffData(data);
    const { tree, treeEntries } = generateTreeList(data.diff_files);

    Object.assign(state, {
      ...convertObjectPropsToCamelCase(data),
      tree: sortTree(tree),
      treeEntries,
    });
  },

  [types.RENDER_FILE](state, file) {
    Object.assign(file, {
      renderIt: true,
    });
  },

  [types.SET_MERGE_REQUEST_DIFFS](state, mergeRequestDiffs) {
    Object.assign(state, {
      mergeRequestDiffs,
    });
  },

  [types.SET_DIFF_VIEW_TYPE](state, diffViewType) {
    Object.assign(state, { diffViewType });
  },

  [types.ADD_COMMENT_FORM_LINE](state, { lineCode }) {
    Vue.set(state.diffLineCommentForms, lineCode, true);
  },

  [types.REMOVE_COMMENT_FORM_LINE](state, { lineCode }) {
    Vue.delete(state.diffLineCommentForms, lineCode);
  },

  [types.ADD_CONTEXT_LINES](state, options) {
    const { lineNumbers, contextLines, fileHash } = options;
    const { bottom } = options.params;
    const diffFile = findDiffFile(state.diffFiles, fileHash);

    removeMatchLine(diffFile, lineNumbers, bottom);

    const lines = addLineReferences(contextLines, lineNumbers, bottom).map(line => ({
      ...line,
      line_code: line.line_code || `${fileHash}_${line.old_line}_${line.new_line}`,
      discussions: line.discussions || [],
    }));

    addContextLines({
      inlineLines: diffFile.highlighted_diff_lines,
      parallelLines: diffFile.parallel_diff_lines,
      contextLines: lines,
      bottom,
      lineNumbers,
    });
  },

  [types.ADD_COLLAPSED_DIFFS](state, { file, data }) {
    prepareDiffData(data);
    const [newFileData] = data.diff_files.filter(f => f.file_hash === file.file_hash);
    const selectedFile = state.diffFiles.find(f => f.file_hash === file.file_hash);
    Object.assign(selectedFile, { ...newFileData });
  },

  [types.EXPAND_ALL_FILES](state) {
    state.diffFiles = state.diffFiles.map(file => ({
      ...file,
      collapsed: false,
    }));
  },

  [types.SET_LINE_DISCUSSIONS_FOR_FILE](state, { discussion, diffPositionByLineCode }) {
    const { latestDiff } = state;

    const discussionLineCode = discussion.line_code;
    const fileHash = discussion.diff_file.file_hash;
    const lineCheck = line =>
      line.line_code === discussionLineCode &&
      isDiscussionApplicableToLine({
        discussion,
        diffPosition: diffPositionByLineCode[line.line_code],
        latestDiff,
      });

    state.diffFiles = state.diffFiles.map(diffFile => {
      if (diffFile.file_hash === fileHash) {
        const file = { ...diffFile };

        if (file.highlighted_diff_lines) {
          file.highlighted_diff_lines = file.highlighted_diff_lines.map(line => {
            if (lineCheck(line)) {
              return {
                ...line,
                discussions: line.discussions.concat(discussion),
              };
            }

            return line;
          });
        }

        if (file.parallel_diff_lines) {
          file.parallel_diff_lines = file.parallel_diff_lines.map(line => {
            const left = line.left && lineCheck(line.left);
            const right = line.right && lineCheck(line.right);

            if (left || right) {
              return {
                left: {
                  ...line.left,
                  discussions: left ? line.left.discussions.concat(discussion) : [],
                },
                right: {
                  ...line.right,
                  discussions: right && !left ? line.right.discussions.concat(discussion) : [],
                },
              };
            }

            return line;
          });
        }

        if (!file.parallel_diff_lines || !file.highlighted_diff_lines) {
          file.discussions = file.discussions.concat(discussion);
        }

        return file;
      }

      return diffFile;
    });
  },

  [types.REMOVE_LINE_DISCUSSIONS_FOR_FILE](state, { fileHash, lineCode, id }) {
    const selectedFile = state.diffFiles.find(f => f.file_hash === fileHash);
    if (selectedFile) {
      if (selectedFile.parallel_diff_lines) {
        const targetLine = selectedFile.parallel_diff_lines.find(
          line =>
            (line.left && line.left.line_code === lineCode) ||
            (line.right && line.right.line_code === lineCode),
        );
        if (targetLine) {
          const side = targetLine.left && targetLine.left.line_code === lineCode ? 'left' : 'right';

          Object.assign(targetLine[side], {
            discussions: [],
          });
        }
      }

      if (selectedFile.highlighted_diff_lines) {
        const targetInlineLine = selectedFile.highlighted_diff_lines.find(
          line => line.line_code === lineCode,
        );

        if (targetInlineLine) {
          Object.assign(targetInlineLine, {
            discussions: [],
          });
        }
      }

      if (selectedFile.discussions && selectedFile.discussions.length) {
        selectedFile.discussions = selectedFile.discussions.filter(
          discussion => discussion.id !== id,
        );
      }
    }
  },
  [types.TOGGLE_FOLDER_OPEN](state, path) {
    state.treeEntries[path].opened = !state.treeEntries[path].opened;
  },
  [types.TOGGLE_SHOW_TREE_LIST](state) {
    state.showTreeList = !state.showTreeList;
  },
  [types.UPDATE_CURRENT_DIFF_FILE_ID](state, fileId) {
    state.currentDiffFileId = fileId;
  },
  [types.OPEN_DIFF_FILE_COMMENT_FORM](state, formData) {
    state.commentForms.push({
      ...formData,
    });
  },
  [types.UPDATE_DIFF_FILE_COMMENT_FORM](state, formData) {
    const { fileHash } = formData;

    state.commentForms = state.commentForms.map(form => {
      if (form.fileHash === fileHash) {
        return {
          ...formData,
        };
      }

      return form;
    });
  },
  [types.CLOSE_DIFF_FILE_COMMENT_FORM](state, fileHash) {
    state.commentForms = state.commentForms.filter(form => form.fileHash !== fileHash);
  },
};
