<template>
  <footer>
    <b-container class="footer-content">
      <div class="copyright">© 1999-2018 Neopets, Inc.<br class="copyright-break"> All rights reserved. Used with permission.</div>
      <b-link :to="'/about'" class="about-link">About</b-link>
    </b-container>
  </footer>
</template>

<style scoped>
footer {
  flex-shrink: 0;
  width: 100%;
  /* border-top: 1px solid #ddd; */
  padding: 15px 0;
  background-color: #f0f0f0;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  font-size: 0.9rem;
  color: #777;
}

.about-link {
  color: #777;
}

.copyright {
  text-align: right;
  font-size: 0.8rem;
}

@media (max-width: 575.98px) {
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