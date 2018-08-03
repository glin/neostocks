<template>
  <div class="heading">
    <slot />
    <hr class="divider">
  </div>
</template>

<style scoped>
.heading {
  display: flex;
  flex-direction: column;
  margin: 0 5px 5px;
  font-size: 1.25rem;
}

.divider {
  margin: 5px 0;
}
</style>
