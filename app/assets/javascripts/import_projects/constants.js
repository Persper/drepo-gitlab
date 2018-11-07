import { __ } from '../locale';

export const STATUSES = {
  FINISHED: 'finished',
  FAILED: 'failed',
  SCHEDULED: 'scheduled',
  STARTED: 'started',
  NONE: 'none',
};

const STATUS_MAP = {};
STATUS_MAP[STATUSES.FINISHED] = {
  icon: 'success',
  text: __('Done'),
  textClass: 'text-success',
};
STATUS_MAP[STATUSES.FAILED] = {
  icon: 'failed',
  text: __('Failed'),
  textClass: 'text-danger',
};
STATUS_MAP[STATUSES.SCHEDULED] = {
  icon: 'pending',
  text: __('Scheduled'),
  textClass: 'text-warning',
};
STATUS_MAP[STATUSES.STARTED] = {
  icon: 'running',
  text: __('Running...'),
  textClass: 'text-info',
};
STATUS_MAP[STATUSES.NONE] = {
  icon: 'created',
  text: __('Not started'),
  textClass: 'text-muted',
};

export default STATUS_MAP;
