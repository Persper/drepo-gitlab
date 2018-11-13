import _ from 'underscore';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { diffModes } from '~/ide/constants';
import {
  LINE_POSITION_LEFT,
  LINE_POSITION_RIGHT,
  TEXT_DIFF_POSITION_TYPE,
  LEGACY_DIFF_NOTE_TYPE,
  DIFF_NOTE_TYPE,
  NEW_LINE_TYPE,
  OLD_LINE_TYPE,
  MATCH_LINE_TYPE,
  LINES_TO_BE_RENDERED_DIRECTLY,
  MAX_LINES_TO_BE_RENDERED,
} from '../constants';

export function findDiffFile(files, hash) {
  return files.filter(file => file.fileHash === hash)[0];
}

export const getReversePosition = linePosition => {
  if (linePosition === LINE_POSITION_RIGHT) {
    return LINE_POSITION_LEFT;
  }

  return LINE_POSITION_RIGHT;
};

export function getFormData(params) {
  const {
    note,
    noteableType,
    noteableData,
    diffFile,
    noteTargetLine,
    diffViewType,
    linePosition,
    positionType,
  } = params;

  const position = JSON.stringify({
    base_sha: diffFile.diffRefs.baseSha,
    start_sha: diffFile.diffRefs.startSha,
    head_sha: diffFile.diffRefs.headSha,
    old_path: diffFile.oldPath,
    new_path: diffFile.newPath,
    position_type: positionType || TEXT_DIFF_POSITION_TYPE,
    old_line: noteTargetLine ? noteTargetLine.oldLine : null,
    new_line: noteTargetLine ? noteTargetLine.newLine : null,
    x: params.x,
    y: params.y,
    width: params.width,
    height: params.height,
  });

  const postData = {
    view: diffViewType,
    line_type: linePosition === LINE_POSITION_RIGHT ? NEW_LINE_TYPE : OLD_LINE_TYPE,
    merge_request_diff_head_sha: diffFile.diffRefs.headSha,
    in_reply_to_discussion_id: '',
    note_project_id: '',
    target_type: noteableData.targetType,
    target_id: noteableData.id,
    return_discussion: true,
    note: {
      note,
      position,
      noteable_type: noteableType,
      noteable_id: noteableData.id,
      commit_id: '',
      type:
        diffFile.diffRefs.startSha && diffFile.diffRefs.headSha
          ? DIFF_NOTE_TYPE
          : LEGACY_DIFF_NOTE_TYPE,
      line_code: noteTargetLine ? noteTargetLine.lineCode : null,
    },
  };

  return postData;
}

export function getNoteFormData(params) {
  const data = getFormData(params);

  return {
    endpoint: params.noteableData.create_note_path,
    data,
  };
}

export const findIndexInInlineLines = (lines, lineNumbers) => {
  const { oldLineNumber, newLineNumber } = lineNumbers;

  return _.findIndex(
    lines,
    line => line.oldLine === oldLineNumber && line.newLine === newLineNumber,
  );
};

export const findIndexInParallelLines = (lines, lineNumbers) => {
  const { oldLineNumber, newLineNumber } = lineNumbers;

  return _.findIndex(
    lines,
    line =>
      line.left &&
      line.right &&
      line.left.oldLine === oldLineNumber &&
      line.right.newLine === newLineNumber,
  );
};

export function removeMatchLine(diffFile, lineNumbers, bottom) {
  const indexForInline = findIndexInInlineLines(diffFile.highlightedDiffLines, lineNumbers);
  const indexForParallel = findIndexInParallelLines(diffFile.parallelDiffLines, lineNumbers);
  const factor = bottom ? 1 : -1;

  diffFile.highlightedDiffLines.splice(indexForInline + factor, 1);
  diffFile.parallelDiffLines.splice(indexForParallel + factor, 1);
}

export function addLineReferences(lines, lineNumbers, bottom) {
  const { oldLineNumber, newLineNumber } = lineNumbers;
  const lineCount = lines.length;
  let matchLineIndex = -1;

  const linesWithNumbers = lines.map((l, index) => {
    const line = convertObjectPropsToCamelCase(l);

    if (line.type === MATCH_LINE_TYPE) {
      matchLineIndex = index;
    } else {
      Object.assign(line, {
        oldLine: bottom ? oldLineNumber + index + 1 : oldLineNumber + index - lineCount,
        newLine: bottom ? newLineNumber + index + 1 : newLineNumber + index - lineCount,
      });
    }

    return line;
  });

  if (matchLineIndex > -1) {
    const line = linesWithNumbers[matchLineIndex];
    const targetLine = bottom
      ? linesWithNumbers[matchLineIndex - 1]
      : linesWithNumbers[matchLineIndex + 1];

    Object.assign(line, {
      metaData: {
        oldPos: targetLine.oldLine,
        newPos: targetLine.newLine,
      },
    });
  }

  return linesWithNumbers;
}

export function addContextLines(options) {
  const { inlineLines, parallelLines, contextLines, lineNumbers } = options;
  const normalizedParallelLines = contextLines.map(line => ({
    left: line,
    right: line,
  }));

  if (options.bottom) {
    inlineLines.push(...contextLines);
    parallelLines.push(...normalizedParallelLines);
  } else {
    const inlineIndex = findIndexInInlineLines(inlineLines, lineNumbers);
    const parallelIndex = findIndexInParallelLines(parallelLines, lineNumbers);
    inlineLines.splice(inlineIndex, 0, ...contextLines);
    parallelLines.splice(parallelIndex, 0, ...normalizedParallelLines);
  }
}

/**
 * Trims the first char of the `richText` property when it's either a space or a diff symbol.
 * @param {Object} line
 * @returns {Object}
 */
export function trimFirstCharOfLineContent(line = {}) {
  // eslint-disable-next-line no-param-reassign
  delete line.text;
  // eslint-disable-next-line no-param-reassign
  line.discussions = [];

  const parsedLine = Object.assign({}, line);

  if (line.richText) {
    const firstChar = parsedLine.richText.charAt(0);

    if (firstChar === ' ' || firstChar === '+' || firstChar === '-') {
      parsedLine.richText = line.richText.substring(1);
    }
  }

  return parsedLine;
}

// This prepares and optimizes the incoming diff data from the server
// by setting up incremental rendering and removing unneeded data
export function prepareDiffData(diffData) {
  const filesLength = diffData.diffFiles.length;
  let showingLines = 0;
  for (let i = 0; i < filesLength; i += 1) {
    const file = diffData.diffFiles[i];

    if (file.parallelDiffLines) {
      const linesLength = file.parallelDiffLines.length;
      for (let u = 0; u < linesLength; u += 1) {
        const line = file.parallelDiffLines[u];
        if (line.left) {
          line.left = trimFirstCharOfLineContent(line.left);
        }
        if (line.right) {
          line.right = trimFirstCharOfLineContent(line.right);
        }
      }
    }

    if (file.highlightedDiffLines) {
      const linesLength = file.highlightedDiffLines.length;
      for (let u = 0; u < linesLength; u += 1) {
        const line = file.highlightedDiffLines[u];
        Object.assign(line, { ...trimFirstCharOfLineContent(line) });
      }
      showingLines += file.parallelDiffLines.length;
    }

    Object.assign(file, {
      renderIt: showingLines < LINES_TO_BE_RENDERED_DIRECTLY,
      collapsed: file.text && showingLines > MAX_LINES_TO_BE_RENDERED,
      discussions: [],
    });
  }
}

export function getDiffPositionByLineCode(diffFiles) {
  return diffFiles.reduce((acc, diffFile) => {
    const { baseSha, headSha, startSha } = diffFile.diffRefs;
    const { newPath, oldPath } = diffFile;

    // We can only use highlightedDiffLines to create the map of diff lines because
    // highlightedDiffLines will also include every parallel diff line in it.
    if (diffFile.highlightedDiffLines) {
      diffFile.highlightedDiffLines.forEach(line => {
        const { lineCode, oldLine, newLine } = line;

        if (lineCode) {
          acc[lineCode] = {
            baseSha,
            headSha,
            startSha,
            newPath,
            oldPath,
            oldLine,
            newLine,
            lineCode,
            positionType: 'text',
          };
        }
      });
    }

    return acc;
  }, {});
}

// This method will check whether the discussion is still applicable
// to the diff line in question regarding different versions of the MR
export function isDiscussionApplicableToLine({ discussion, diffPosition, latestDiff }) {
  const { lineCode, ...diffPositionCopy } = diffPosition;

  if (discussion.original_position && discussion.position) {
    const originalRefs = convertObjectPropsToCamelCase(discussion.original_position);
    const refs = convertObjectPropsToCamelCase(discussion.position);

    return _.isEqual(refs, diffPositionCopy) || _.isEqual(originalRefs, diffPositionCopy);
  }

  return latestDiff && discussion.active && lineCode === discussion.line_code;
}

export const generateTreeList = files =>
  files.reduce(
    (acc, file) => {
      const { fileHash, addedLines, removedLines, newFile, deletedFile, newPath } = file;
      const split = newPath.split('/');

      split.forEach((name, i) => {
        const parent = acc.treeEntries[split.slice(0, i).join('/')];
        const path = `${parent ? `${parent.path}/` : ''}${name}`;

        if (!acc.treeEntries[path]) {
          const type = path === newPath ? 'blob' : 'tree';
          acc.treeEntries[path] = {
            key: path,
            path,
            name,
            type,
            tree: [],
          };

          const entry = acc.treeEntries[path];

          if (type === 'blob') {
            Object.assign(entry, {
              changed: true,
              tempFile: newFile,
              deleted: deletedFile,
              fileHash,
              addedLines,
              removedLines,
            });
          } else {
            Object.assign(entry, {
              opened: true,
            });
          }

          (parent ? parent.tree : acc.tree).push(entry);
        }
      });

      return acc;
    },
    { treeEntries: {}, tree: [] },
  );

export const getDiffMode = diffFile => {
  const diffModeKey = Object.keys(diffModes).find(key => diffFile[`${key}File`]);
  return diffModes[diffModeKey] || diffModes.replaced;
};
