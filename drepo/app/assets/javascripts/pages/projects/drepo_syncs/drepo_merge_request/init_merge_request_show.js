import ZenMode from '~/zen_mode';
import { handleLocationHash } from '~/lib/utils/common_utils';

export default function() {
  new ZenMode(); // eslint-disable-line no-new
  handleLocationHash();
}
