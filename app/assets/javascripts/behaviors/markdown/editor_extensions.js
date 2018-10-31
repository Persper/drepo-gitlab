import {
  HistoryExtension,
  PlaceholderExtension,
} from 'tiptap-extensions'

import BoldMark from './marks/bold';
import CodeMark from './marks/code';
import InlineDiffMark from './marks/inline_diff';
import InlineHTMLMark from './marks/inline_html';
import ItalicMark from './marks/italic';
import LinkMark from './marks/link';
import MathMark from './marks/math';
import StrikeMark from './marks/strike';

import BlockquoteNode from './nodes/blockquote';
import BulletListNode from './nodes/bullet_list';
import CodeBlockNode from './nodes/code_block';
import DescriptionDetailsNode from './nodes/description_details';
import DescriptionListNode from './nodes/description_list';
import DescriptionTermNode from './nodes/description_term';
import DetailsNode from './nodes/details';
import DocNode from './nodes/doc';
import EmojiNode from './nodes/emoji';
import HardBreakNode from './nodes/hard_break';
import HeadingNode from './nodes/heading';
import HorizontalRuleNode from './nodes/horizontal_rule.js';
import ImageNode from './nodes/image';
import ListItemNode from './nodes/list_item';
import OrderedListNode from './nodes/ordered_list';
import OrderedTaskListNode from './nodes/ordered_task_list';
import ParagraphNode from './nodes/paragraph';
import ReferenceNode from './nodes/reference';
import SummaryNode from './nodes/summary';
import TableBodyNode from './nodes/table_body';
import TableCellNode from './nodes/table_cell';
import TableHeadNode from './nodes/table_head';
import TableHeaderRowNode from './nodes/table_header_row';
import TableOfContentsNode from './nodes/table_of_contents';
import TableRowNode from './nodes/table_row';
import TableNode from './nodes/table';
import TaskListItemNode from './nodes/task_list_item';
import TaskListNode from './nodes/task_list';
import TextNode from './nodes/text';
import VideoNode from './nodes/video';

// The filters referenced in lib/banzai/pipeline/gfm_pipeline.rb convert
// GitLab Flavored Markdown (GFM) to HTML.
// The nodes and marks referenced here convert that same HTML to GFM to be copied to the clipboard.
// Every filter in lib/banzai/pipeline/gfm_pipeline.rb that generates HTML
// from GFM should have a node or mark here.
// The GFM-to-HTML-to-GFM cycle is tested in spec/features/copy_as_gfm_spec.rb.

export default [
  new HistoryExtension,
  new PlaceholderExtension,

  new DocNode,
  new ParagraphNode,
  new TextNode,

  new EmojiNode,
  new VideoNode,
  new DetailsNode,
  new SummaryNode,
  new ReferenceNode,
  new HorizontalRuleNode,
  new TaskListNode,
  new OrderedTaskListNode,
  new TaskListItemNode,
  new TableOfContentsNode,
  new DescriptionListNode,
  new DescriptionTermNode,
  new DescriptionDetailsNode,
  new TableNode,
  new TableHeadNode,
  new TableBodyNode,
  new TableRowNode,
  new TableHeaderRowNode,
  new TableCellNode,

  new BlockquoteNode,
  new BulletListNode,
  new CodeBlockNode,
  new HeadingNode({ maxLevel: 6 }),
  new HardBreakNode,
  new ImageNode,
  new ListItemNode,
  new OrderedListNode,

  new BoldMark,
  new LinkMark,
  new ItalicMark,
  new StrikeMark,

  new InlineDiffMark,
  new InlineHTMLMark,
  new MathMark,
  new CodeMark,

  // new SuggestionsPlugin,
  // new MentionNode,
]
