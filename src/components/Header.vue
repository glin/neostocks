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
          <b-nav-item to="/about">About</b-nav-item>
        </b-navbar-nav>

        <b-navbar-nav class="ml-auto">
          <b-nav-form class="search-form">
            <b-form-input :formatter="formatSearch" class="search-input" type="text" placeholder="search tickers" @input="onSearch" />
            <b-button class="search-btn" variant="default">
              <SearchIcon class="search-icon" />
            </b-button>
          </b-nav-form>
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

.search-form {
  position: relative;
}

.search-input {
  padding-right: 50px;
  min-width: 200px;
  border-radius: 1px;
  transition: none;
}

.search-input:focus {
  box-shadow: inset 0 0 0 1px rgba(0, 123, 255, 0.25);
}

.search-btn {
  position: absolute;
  right: 0;
  border: none;
  background: transparent;
}

.search-btn:focus,
.search-btn:hover {
  box-shadow: none;
}

.search-icon {
  display: block;
  opacity: 0.6;
}

.search-btn:focus,
.search-btn:hover > .search-icon {
  opacity: 1;
}
</style>

<script>
import SearchIcon from '@mdi/svg/svg/magnify.svg'

export default {
  components: {
    SearchIcon
  },
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