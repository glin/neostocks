<template>
  <b-nav :class="navClass" tabs>
    <b-nav-item :active="period === '1d'" @click="navigate('')">1 day</b-nav-item>
    <b-nav-item :active="period === '5d'" @click="navigate('?period=5d')">5 days</b-nav-item>
    <b-nav-item :active="period === '1m'" @click="navigate('?period=1m')">1 month</b-nav-item>
    <b-nav-item :active="period === 'all'" @click="navigate('?period=all')">All</b-nav-item>
  </b-nav>
</template>

<style scoped>
.nav-link:hover,
.nav-link:focus {
  border-color: transparent;
}

.nav-link.active {
  /* border-color: #893a98 #e1e4e8 transparent !important; */
  border-color: #f4a549 #e1e4e8 transparent !important;
  border-width: 3px 1px 1px;
  border-radius: 2px 2px 0 0;
}

@media (max-width: 575.98px) {
  .nav-item {
    flex-basis: 0;
    flex-grow: 1;
    text-align: center;
    white-space: nowrap;
  }
}
</style>

<script>
export default {
  props: {
    period: {
      type: String,
      default: '1d'
    },
    justify: {
      type: String,
      default: 'left',
      validator(val) {
        return val === 'left' || val === 'right'
      }
    }
  },

  computed: {
    navClass() {
      return this.justify === 'right' ? 'justify-content-end' : null
    }
  },

  methods: {
    navigate(location) {
      this.$router.push(location)
    }
  }
}
</script>