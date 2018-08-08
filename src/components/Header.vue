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
          <b-nav-form class="search-form" @submit="handleSearch">
            <label for="ticker-search-input" class="search-icon" @mousedown.prevent>
              <SearchIcon />
            </label>
            <b-form-input id="ticker-search-input" :value="search" :formatter="formatSearch" class="search-input" type="text" placeholder="search tickers" autocomplete="off" @input="onSearch" @focus.native="handleSearchInputFocus(true)" @blur.native="handleSearchInputFocus(false)" @keydown.up.prevent.native="changeSelectedIndex(-1)" @keydown.down.prevent.native="changeSelectedIndex(1)" />
            <b-list-group v-if="showSearchResults" ref="searchResults" class="search-results" @mouseout="handleSearchResultsHover(-1)">
              <b-list-group-item v-for="(company, index) in searchResults" ref="searchResultItems" :key="company.ticker" :to="company.href" :class="{ hover: isSelected(index) }" class="search-result-item" active-class="test" tabindex="-1" @mouseover.native="handleSearchResultsHover(index)" @click.native="clearSearch">
                <img :src="company.logo" :alt="company.ticker" class="company-logo">
                <span>{{ company.ticker }}</span>
              </b-list-group-item>
              <b-list-group-item v-if="search && searchResults.length === 0" class="search-result-item">
                <span class="no-results-found">No tickers found</span>
              </b-list-group-item>
            </b-list-group>
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
  padding-left: 36px;
  width: 200px;
  border-radius: 2px;
  transition: none;
}

.search-input:focus {
  box-shadow: inset 0 0 0 1px rgba(0, 123, 255, 0.25);
}

.search-icon {
  display: flex;
  justify-content: center;
  position: absolute;
  left: 0;
  width: 36px;
  opacity: 0.6;
}

.search-results {
  position: absolute;
  top: 100%;
  width: 100%;
  max-height: 420px;
  overflow-y: auto;
  border: 1px solid rgba(0, 0, 0, 0.125);
  border-top: none;
  border-bottom: none;
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.15);
}

.search-result-item,
.search-result-item.active {
  padding: 0.35rem 0.7rem;
  border-radius: 0;
  color: #495057;
  background-color: #fff;
  border: 1px solid rgba(0, 0, 0, 0.125);
  border-right: none;
  border-left: none;
}

.search-result-item:first-child {
  border-top: none;
}

.search-result-item:hover {
  background-color: #fff;
}

.search-result-item.hover {
  background-color: #eee;
}

.company-logo {
  margin-right: 0.25em;
  height: 25px;
}

.no-results-found {
  font-size: 0.85rem;
  font-weight: 600;
}
</style>

<script>
import SearchIcon from '@mdi/svg/svg/magnify.svg'

export default {
  components: {
    SearchIcon
  },

  props: {
    search: {
      type: String,
      required: true
    },
    onSearch: {
      type: Function,
      required: true
    },
    searchResults: {
      type: Array,
      required: true
    },
    clearSearch: {
      type: Function,
      required: true
    },
    query: {
      type: String,
      required: true
    }
  },

  data() {
    return {
      selectedIndex: -1,
      searchInputFocused: false,
      searchResultsHovered: false
    }
  },

  computed: {
    showSearchResults() {
      return this.searchInputFocused || this.searchResultsHovered
    }
  },

  watch: {
    searchResults(newSearchResults) {
      if (newSearchResults.length === 1) {
        this.selectedIndex = 0
      } else {
        this.selectedIndex = -1
      }
    }
  },

  methods: {
    formatSearch(val) {
      // only allow alpha, whitespace, separator characters
      return val.toUpperCase().replace(/[^A-Z\s,]/g, '')
    },
    isSelected(index) {
      return this.selectedIndex === index
    },
    changeSelectedIndex(n) {
      this.selectedIndex =
        (this.selectedIndex + n + this.searchResults.length) %
        this.searchResults.length
    },
    handleSearchInputFocus(focused) {
      this.searchInputFocused = focused
    },
    handleSearchResultsHover(index) {
      this.selectedIndex = index
      this.searchResultsHovered = index > -1
    },
    handleSearch() {
      if (this.selectedIndex >= 0) {
        const selected = this.$refs.searchResultItems[this.selectedIndex]
        selected.$el.click()
      } else if (this.search) {
        this.clearSearch()
        const query = { search: this.search }
        if (this.$route.query.period) {
          query.period = this.$route.query.period
        }
        this.$router.push({ path: '/', query: query })
      }
    }
  }
}
</script>