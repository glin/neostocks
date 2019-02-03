<template>
  <b-container class="update-time">
    <div
      v-b-tooltip="{ delay: { show: 300 }, placement: 'bottom' }"
      v-if="updateTimeString"
      :title="updateTimeString"
    >last updated {{ updateTimeSince }}</div>
  </b-container>
</template>

<script>
import { mapState } from 'vuex'
import bContainer from 'bootstrap-vue/es/components/layout/container'
import bTooltip from 'bootstrap-vue/es/directives/tooltip/tooltip'

import { timeSince } from '../date'

export default {
  components: {
    bContainer
  },

  directives: {
    bTooltip
  },

  computed: {
    updateTimeUTC() {
      return this.updateTime ? new Date(this.updateTime.UTC) : null
    },
    updateTimeNST() {
      return this.updateTime ? new Date(this.updateTime.NST) : null
    },
    updateTimeString() {
      return this.updateTimeNST ? this.updateTimeNST.toLocaleString() + ' NST' : null
    },
    updateTimeSince() {
      return timeSince(this.updateTimeUTC, this.now)
    },
    ...mapState({
      updateTime: state => state.stocks.updateTime,
      now: state => state.app.now
    })
  }
}
</script>

<style lang="scss" scoped>
@import '../assets/scss/variables';

.update-time {
  display: flex;
  justify-content: flex-end;
  padding: 0.375rem 0.25rem;
  font-style: italic;
  font-size: 0.8125rem;
  color: #555;
}

@include media-breakpoint-down(sm) {
  .update-time {
    justify-content: center;
  }
}
</style>