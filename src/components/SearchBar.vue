<template>
  <b-nav-form class="search-form" @submit="handleSubmit" @keydown.esc="showResults(false)">
    <label for="ticker-search-input" class="search-icon" aria-hidden="true" @mousedown.prevent>
      <SearchIcon/>
    </label>
    <b-form-input
      id="ticker-search-input"
      ref="searchInput"
      :value="value"
      :formatter="formatSearch"
      class="search-input"
      type="text"
      placeholder="search tickers"
      autocomplete="off"
      @input="handleChange"
      @focus.native="showResults(true)"
      @blur.native="showResults(false)"
      @keydown.up.prevent.native="changeSelectedIndex(-1)"
      @keydown.down.prevent.native="changeSelectedIndex(1)"
    />
    <b-list-group
      v-if="resultsVisible"
      ref="searchResults"
      class="search-results"
      @mouseout="handleResultsHover(-1)"
    >
      <b-list-group-item
        v-for="(company, index) in results"
        ref="searchResultItems"
        :key="company.ticker"
        :to="company.location"
        :class="{ hover: isSelected(index) }"
        class="search-result-item"
        tabindex="-1"
        @mouseover.native="handleResultsHover(index)"
        @click.native="handleSubmit"
        @mousedown.prevent.native
      >
        <img :src="company.logo" class="company-logo" alt>
        <span>{{ company.ticker }}</span>
      </b-list-group-item>
      <b-list-group-item v-if="value && results.length === 0" class="search-result-item">
        <span class="no-results">No results found</span>
      </b-list-group-item>
    </b-list-group>
  </b-nav-form>
</template>

<script>
import bFormInput from 'bootstrap-vue/es/components/form-input/form-input'
import bListGroup from 'bootstrap-vue/es/components/list-group/list-group'
import bListGroupItem from 'bootstrap-vue/es/components/list-group/list-group-item'
import bNavForm from 'bootstrap-vue/es/components/nav/nav-form'

import SearchIcon from '@mdi/svg/svg/magnify.svg'

export default {
  components: {
    bFormInput,
    bListGroup,
    bListGroupItem,
    bNavForm,
    SearchIcon
  },

  props: {
    value: {
      type: String,
      required: true
    },
    results: {
      type: Array,
      required: true
    },
    onChange: {
      type: Function,
      required: true
    },
    onSubmit: {
      type: Function,
      required: true
    }
  },

  data() {
    return {
      selectedIndex: -1,
      resultsVisible: false
    }
  },

  watch: {
    results(newResults) {
      if (newResults.length === 1) {
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
      let numItems = this.results.length
      if (this.results.length === 0) return
      // temporary shift to count the "no selection" item at -1
      numItems += 1
      this.selectedIndex += 1
      this.selectedIndex = (this.selectedIndex + n + numItems) % numItems
      this.selectedIndex -= 1
    },
    handleResultsHover(index) {
      this.selectedIndex = index
    },
    handleChange(value) {
      this.resultsVisible = value.length > 0
      this.onChange(value)
    },
    handleSubmit() {
      if (this.selectedIndex >= 0) {
        const selected = this.$refs.searchResultItems[this.selectedIndex]
        selected.$el.click()
      } else if (this.value && this.results.length > 0) {
        this.onSubmit()
      } else {
        return
      }
      this.onChange('')
      this.$refs.searchInput.$el.blur()
    },
    showResults(visible) {
      this.resultsVisible = visible
    }
  }
}
</script>

<style lang="scss" scoped>
@import '../assets/scss/variables';

.search-form {
  position: relative;
  max-width: 200px;
  min-width: 120px;
}

.search-input {
  padding-left: 36px;
  width: 100%;
  border-radius: 2px;
  border-top: none;
  border-left: none;
  border-right: none;
  background-color: transparent;
}

@include media-breakpoint-down(xs) {
  .search-form {
    margin: 0.5rem 0;
  }
}

@include media-breakpoint-only(sm) {
  .search-input::placeholder {
    font-size: 0.9rem;
  }
}

.search-input:focus {
  border-color: $light-orange;
  box-shadow: 0 2px 0px -1px $light-orange;
}

.search-icon {
  display: flex;
  justify-content: center;
  position: absolute;
  left: 0;
  width: 36px;
  opacity: 0.5;
}

.search-icon:hover {
  opacity: 0.8;
}

.search-results {
  position: absolute;
  top: 100%;
  width: 100%;
  min-width: 160px;
  max-height: 420px;
  overflow-y: auto;
  border: 1px solid rgba(0, 0, 0, 0.125);
  border-top: none;
  border-bottom: none;
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.15);
}

.search-result-item,
.search-result-item.active {
  display: flex;
  align-items: center;
  min-height: 45px;
  padding: 0.35rem 0.7rem;
  border-radius: 0;
  color: #495057;
  background-color: #fff;
  border: 1px solid #fff;
  border-right: none;
  border-left: none;
}

.search-result-item:first-child {
  border-top: none;
}

.search-result-item.hover {
  background-color: hsl(210, 13%, 95%);
}

.no-results {
  font-size: 0.9rem;
}

.company-logo {
  margin-right: 10px;
  height: 25px;
}
</style>