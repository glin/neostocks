<template>
  <b-navbar toggleable fixed="top" variant="light" type="light" class="header">
    <b-container>
      <b-navbar-toggle target="nav-menu-collapse" />
      <b-navbar-brand :to="{ path: '/', query }" class="brand">
        <img class="logo" src="../assets/neostocks.png"> neostocks
      </b-navbar-brand>
      <b-collapse id="nav-menu-collapse" v-model="showNavMenuCollapse" is-nav>
        <b-navbar-nav>
          <b-nav-item :to="{ path: '/bargain', query }">Bargain</b-nav-item>
          <b-nav-item :to="{ path: '/hot', query }">Hot</b-nav-item>
          <b-nav-item :to="{ path: '/index', query }">Index</b-nav-item>
        </b-navbar-nav>

        <b-navbar-nav class="ml-auto">
          <SearchBar :value="search" :results="searchResults" :on-change="onSearchChange" :on-submit="onSearchSubmit" />
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

#nav-menu-collapse {
  transition: none;
}

.nav-link.active {
  font-weight: 600;
  color: rgba(0, 0, 0, 0.7) !important;
}
</style>

<script>
import SearchBar from './SearchBar'

export default {
  components: {
    SearchBar
  },

  props: {
    search: {
      type: String,
      required: true
    },
    searchResults: {
      type: Array,
      required: true
    },
    onSearchChange: {
      type: Function,
      required: true
    },
    onSearchSubmit: {
      type: Function,
      required: true
    },
    query: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      showNavMenuCollapse: false
    }
  },

  watch: {
    $route() {
      this.showNavMenuCollapse = false
    }
  }
}
</script>