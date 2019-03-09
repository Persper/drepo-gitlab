<template>
  <div>
    <div class="avatar-cell d-none d-sm-block">
      <img :src="blockiesImage" class="avatar s36 d-none d-sm-inline" />
    </div>
    <span class="mono wrap ng-binding">{{ accountAddress }}</span>
    <p class="ether-amount"><b>Ether:</b> {{ accountBalance }}</p>
  </div>
</template>

<script>
import blockies from 'ethereum-blockies-png';

export default {
  name: 'AccountInfo',
  props: {
    accountAddress: {
      type: String,
      required: true,
    },
    accountBalance: {
      type: String,
      required: true,
    },
  },
  computed: {
    blockiesImage() {
      return blockies.createDataURL({
        seed: this.accountAddress.toLowerCase(),
        size: 8,
        scale: 16,
      });
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.addressIdenticon.float {
  float: left;
  margin-right: 0.5rem;
}
.addressIdenticon.med {
  width: 3rem;
  height: 3rem;
  padding: 0;
}
.wrap {
  word-wrap: break-word;
}
.ether-amount {
  margin-top: 1.5rem;
}
</style>
