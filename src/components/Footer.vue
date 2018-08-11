<template>
  <footer>
    <b-container class="footer-content">
      <b-link :to="'/about'" class="about-link">About</b-link>
      <div class="copyright">© 1999-2018 Neopets, Inc.<br class="copyright-break"> All rights reserved. Used with permission.</div>
    </b-container>
  </footer>
</template>

<style scoped>
footer {
  flex-shrink: 0;
  width: 100%;
  /* border-top: 1px solid #ddd; */
  padding: 10px 0;
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