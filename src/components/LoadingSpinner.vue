<template>
  <div class="loader">
    <clip-loader
      :color="color"
      class="loader"
    />
  </div>
</template>

<style scoped>
.loader {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
}
</style>

<script>
import ClipLoader from 'vue-spinner/src/ClipLoader.vue'

export default {
  components: {
    ClipLoader
  },

  props: {
    color: {
      type: String,
      default: '#3398db'
    }
  }
}
</script>