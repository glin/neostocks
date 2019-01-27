<template>
  <div class="text-center">
    <b-link to="/">
      <img src="/static/404.png" alt="404, page not found">
    </b-link>
    <h1>page not found</h1>
  </div>
</template>

<script>
import bLink from 'bootstrap-vue/es/components/link/link'

export default {
  components: {
    bLink
  }
}
</script>

<style scoped>
img {
  margin-top: 2rem;
  margin-bottom: 1rem;
}

h1 {
  font-size: 1.75rem;
}
</style>