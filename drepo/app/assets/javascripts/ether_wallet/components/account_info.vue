<template>
  <div>
    <div
      class="addressIdenticon med float"
      blockie-address="0x2e638f5383d8a502e615ad0d88176a1d15b39c72"
      watch-var="wallet"
      style="background-image: url(&quot;data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAADpUlEQVR4Xu3dvW0WURCF4ftJFoGLoQASYgJCp3RATAnIbZASEkBE4BLcAy04QEhQxBOMhn3Jh73fmXfPnP3x3tuvlx9/D/z78u4eqs/59voP1b9/vqN6LZ5e/4fvL/QTbgFA+o0DHAA5ABGcA5B88yMsB8gBCOEcgOTLAU5XAbNXMY2ARgB5WCOA5GsENAKGb2Q1AhoB5GGNAJKvEdAIaAT0MEhMRB9mlQHKAMLfKQOQfP9BBnjz8Se9D6AWhvrz41g9/vbffwsAQyAAls9ga/85ARAAyhDV6ytpjQCSPwdYb4HY//W/PwdAAsoAZQBEyMrLAHgv3uQvA6yfgQHQnUBioAxQBiCAtLgMUAYghroMJPkKgYXA5SMwB8gB7H0A1I8dREPQ1dfPDnB1AfUycBrgAECCA+DiAgZAAJACjQC8jJoWMAcg/v1GSgBYAwqBpt/6y9gACIBuBAkDZQBR75QBpjNMI+DiAAdAAJQBhIEygKhXBhj/6+ZGwMUBHgcA9T9fH3/rf0H1D59eUf10cQBgBwIABdTyHMAUzAFMv5MDoIBangOYgjmA6ZcDoH5cngOYhDmA6ZcDoH5cngOYhDmA6ZcDoH5cngOYhDmA6ZcDoH5cngOYhDmA6ZcDoH5cngOYhDmA6bffAT6/faL9AnTLEn2Yoq9kYf/5jR51MN259RYAhoC+1h0A+EZNDmCbduUAZgCNgDKA7R7eCGgEkAcVAvEDE6T+8W3jcoAcgBjMAXIAAqirAJKvEXC6CugqgM6hbgXbn7aVAcoAdAKWAUi+MkAZAHcs6T5A9wHIgzgD6PbxtPq+EMIPk1T/8TeC9HGuPo9XAbevPwCQgAC4uIABEACkwPQIawRQ+/Z/6jYAAqAvhQoDZQBRr/sA3QfYfgZtX38Z4OIOFgABUAgUBhoBol4hsBC4/Qzavv4ywMUdjAHQMwD1v3y5PksIgOUIBcDyBuryA0AVXF4fAMsbqMsPAFVweX0ALG+gLj8AVMHl9QGwvIG6/ABQBZfXB8DyBuryA0AVXF4fAMsbqMsPAFVweX0ALG+gLj8AVMHl9QyAfi5eF6DvE+jxtf/T69fj8zeCtAH6A/T4AYA7hmgDAsC+M6j65QBoAdqA6RMoAALANo2aJliPj/0/OQB+J29awAAoBBID0wDr8csA1P75T8QEAI4g7H8ZQEOYEqzHD4AyADEwDbAevwxA7S8D8N+3K8GNgDtCOAcg+XKAHAC3rFEHUwf9BxOuef3Uxa4AAAAAAElFTkSuQmCC&quot;);"
    ></div>
    <span class="mono wrap ng-binding">{{ accountAddress }}</span>
    <p class="ether-amount">Ether: {{ accountBalance }}</p>
  </div>
</template>

<script>
export default {
  name: 'AccountInfo',
  props: {
    accountAddress: {
      type: String,
      required: true
    },
    accountBalance: {
      type: String,
      required: true
    }
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
  margin-top: 40px;
}
</style>
