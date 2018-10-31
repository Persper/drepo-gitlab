import DocNode from './nodes/doc';
import ParagraphNode from './nodes/paragraph';
import TextNode from './nodes/text';

import BlockquoteNode from './nodes/blockquote';
import CodeBlockNode from './nodes/code_block';
import HardBreakNode from './nodes/hard_break';
import HeadingNode from './nodes/heading';
import HorizontalRuleNode from './nodes/horizontal_rule.js';
import ImageNode from './nodes/image';

import TableNode from './nodes/table';
import TableHeadNode from './nodes/table_head';
import TableBodyNode from './nodes/table_body';
import TableHeaderRowNode from './nodes/table_header_row';
import TableRowNode from './nodes/table_row';
import TableCellNode from './nodes/table_cell';

import EmojiNode from './nodes/emoji';
import ReferenceNode from './nodes/reference';

import TableOfContentsNode from './nodes/table_of_contents';
import VideoNode from './nodes/video';

import BulletListNode from './nodes/bullet_list';
import OrderedListNode from './nodes/ordered_list';
import ListItemNode from './nodes/list_item';

import DescriptionListNode from './nodes/description_list';
import DescriptionTermNode from './nodes/description_term';
import DescriptionDetailsNode from './nodes/description_details';

import TaskListNode from './nodes/task_list';
import OrderedTaskListNode from './nodes/ordered_task_list';
import TaskListItemNode from './nodes/task_list_item';

import SummaryNode from './nodes/summary';
import DetailsNode from './nodes/details';

import BoldMark from './marks/bold';
import ItalicMark from './marks/italic';
import StrikeMark from './marks/strike';
import InlineDiffMark from './marks/inline_diff';

import LinkMark from './marks/link';
import CodeMark from './marks/code';
import MathMark from './marks/math';
import InlineHTMLMark from './marks/inline_html';

// The filters referenced in lib/banzai/pipeline/gfm_pipeline.rb convert
// GitLab Flavored Markdown (GFM) to HTML.
// The nodes and marks referenced here convert that same HTML to GFM to be copied to the clipboard.
// Every filter in lib/banzai/pipeline/gfm_pipeline.rb that generates HTML
// from GFM should have a node or mark here.
// The GFM-to-HTML-to-GFM cycle is tested in spec/features/copy_as_gfm_spec.rb.

export default [
  new DocNode,
  new ParagraphNode,
  new TextNode,

  new BlockquoteNode,
  new CodeBlockNode,
  new HardBreakNode,
  new HeadingNode({ maxLevel: 6 }),
  new HorizontalRuleNode,
  new ImageNode,

  new TableNode,
  new TableHeadNode,
  new TableBodyNode,
  new TableHeaderRowNode,
  new TableRowNode,
  new TableCellNode,

  new EmojiNode,
  new ReferenceNode,

  new TableOfContentsNode,
  new VideoNode,

  new BulletListNode,
  new OrderedListNode,
  new ListItemNode,

  new DescriptionListNode,
  new DescriptionTermNode,
  new DescriptionDetailsNode,

  new TaskListNode,
  new OrderedTaskListNode,
  new TaskListItemNode,

  new SummaryNode,
  new DetailsNode,

  new BoldMark,
  new ItalicMark,
  new StrikeMark,
  new InlineDiffMark,

  new LinkMark,
  new CodeMark,
  new MathMark,
  new InlineHTMLMark,
]
