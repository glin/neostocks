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

import { toDateTimeStringNST, timeSince } from '../date'

export default {
  components: {
    bContainer
  },

  directives: {
    bTooltip
  },

  computed: {
    updateTimeString() {
      return toDateTimeStringNST(this.updateTime) + ' NST'
    },
    updateTimeSince() {
      return timeSince(this.updateTime, this.now)
    },
    ...mapState({
      updateTime: state => new Date(state.stocks.updateTime),
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