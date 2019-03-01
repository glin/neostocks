<template>
  <div class="content-card d-flex flex-column">
    <slot />
  </div>
</template>

<style>
.content-card {
  padding: 0.7rem 0.7rem 0.625rem;
  background-color: #fff;
  box-shadow: 0 1px 4px 0 hsla(0, 0%, 0%, 0.25);
  border-radius: 2px;
}
</style>