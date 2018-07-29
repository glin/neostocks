<template>
  <div class="heading">
    <slot />
    <hr class="divider">
  </div>
</template>

<style scoped>
.heading {
  margin: 0 5px 10px;
  font-size: 1.2rem;
}

.divider {
  margin: 5px 0;
}

@media (max-width: 575.98px) {
  .heading {
    text-align: center;
  }
}
</style>
