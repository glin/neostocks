<template>
  <footer>
    <b-container class="footer">Images © 1999-2019 Neopets, Inc.
      <div class="footer-2">
        All rights reserved.
        <span class="separator">·</span>
        <b-link to="/privacy" class="footer-link">Privacy Policy</b-link>
        <span class="separator">·</span>
        <b-link to="/about" class="footer-link">About</b-link>
      </div>
    </b-container>
  </footer>
</template>

<script>
import bContainer from 'bootstrap-vue/es/components/layout/container'
import bLink from 'bootstrap-vue/es/components/link/link'

export default {
  components: {
    bContainer,
    bLink
  }
}
</script>

<style lang="scss" scoped>
@import '../assets/scss/variables';

.footer {
  text-align: center;
  padding: 1.25rem 1rem;
  font-size: 0.75rem;
  color: hsl(0, 0%, 55%);
}

.footer-link {
  color: hsl(0, 0%, 55%);
}

.separator {
  margin: 0 0.15rem;
}

@include media-breakpoint-up(xs) {
  .footer-2 {
    display: inline-block;
  }
}
</style>