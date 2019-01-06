<template>
  <footer>
    <b-container class="footer">
      <div class="copyright">© 1999-2019 Neopets, Inc.<br class="copyright-break"> All rights reserved. Used with permission.</div>
      <b-link :to="'/about'" class="about-link">About</b-link>
    </b-container>
  </footer>
</template>

<style scoped>
.footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 0;
  border-top: 1px solid #e2e5e8;
  font-size: 0.9rem;
  color: #999;
}

.about-link {
  color: #6f6f6f;
}

.copyright {
  text-align: right;
  font-size: 0.8rem;
}

@media (max-width: 575.98px) {
  .footer {
    padding: 1rem;
    border-top: none;
  }

  .copyright {
    font-size: 0.7rem;
  }
}

@media (min-width: 576px) {
  .copyright-break {
    display: none;
  }
}
</style>

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