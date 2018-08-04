<template>
  <b-navbar toggleable sticky variant="light" type="light" class="header">
    <b-container>
      <b-navbar-toggle target="nav-menu-collapse" />
      <b-navbar-brand :to="'/' + query" class="brand">
        <img class="logo" src="../assets/neostocks.png"> neostocks
      </b-navbar-brand>
      <b-collapse id="nav-menu-collapse" is-nav>
        <b-navbar-nav>
          <b-nav-item :to="'/bargain' + query">Bargain</b-nav-item>
          <b-nav-item :to="'/hot' + query">Hot</b-nav-item>
          <b-nav-item :to="'/index' + query">Index</b-nav-item>
        </b-navbar-nav>

        <b-navbar-nav class="ml-auto">
          <b-form-input :formatter="formatSearch" type="text" placeholder="search tickers" @input="onSearch" />
        </b-navbar-nav>
      </b-collapse>
    </b-container>
  </b-navbar>
</template>

<style scoped>
.header {
  box-shadow: 0 2px 4px -1px rgba(0, 0, 0, 0.25);
}

.brand:hover {
  color: rgb(0, 0, 0, 0.7);
}

.logo {
  width: 25px;
  height: 25px;
}
</style>

<script>
export default {
  props: {
    onSearch: {
      type: Function,
      required: true
    }
  },
  computed: {
    query() {
      return this.$route.query.period
        ? `?period=${this.$route.query.period}`
        : ''
    }
  },
  methods: {
    formatSearch(val) {
      // only allow alpha, whitespace, separator characters
      return val.toUpperCase().replace(/[^A-Z\s,]/g, '')
    }
  }
}
</script>