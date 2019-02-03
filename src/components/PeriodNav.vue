<template>
  <b-nav class="nav-tabs" tabs>
    <b-nav-item :active="period === '1d'" @click="navigate('')">1 day</b-nav-item>
    <b-nav-item :active="period === '5d'" @click="navigate('5d')">5 days</b-nav-item>
    <b-nav-item :active="period === '1m'" @click="navigate('1m')">1 month</b-nav-item>
    <b-nav-item :active="period === 'all'" @click="navigate('all')">All</b-nav-item>
  </b-nav>
</template>

<script>
import bNav from 'bootstrap-vue/es/components/nav/nav'
import bNavItem from 'bootstrap-vue/es/components/nav/nav-item'

export default {
  components: {
    bNav,
    bNavItem
  },

  props: {
    period: {
      type: String,
      default: '1d'
    }
  },

  methods: {
    navigate(period) {
      const query = { ...this.$route.query }
      if (period) {
        query.period = period
      } else {
        delete query.period
      }
      this.$router.push({ query })
    }
  }
}
</script>

<style lang="scss" scoped>
@import '../assets/scss/variables';

.nav-tabs {
  border-bottom: 1px solid hsl(210, 13%, 93%);
}

.nav-link,
.nav-link:hover {
  border-top: 3px solid;
  border-color: transparent;
}

.nav-link.active {
  /* border-color: #893a98 #e1e4e8 transparent !important; */
  border-color: $light-orange hsl(214, 13%, 90%) transparent !important;
  border-radius: 2px 2px 0 0;
}

@include media-breakpoint-down(md) {
  .nav-item {
    flex-basis: 0;
    flex-grow: 1;
    text-align: center;
    white-space: nowrap;
  }
}
</style>