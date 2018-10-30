<template>
  <b-container class="update-time">
    <div v-if="updateTimeString" :title="updateTimeString">
      updated {{ updateTimeSince }}
    </div>
  </b-container>
</template>

<style scoped>
.update-time {
  display: flex;
  justify-content: flex-end;
  padding: 6px 4px;
  font-style: italic;
  font-size: small;
  color: #555;
}

@media (max-width: 575.98px) {
  .update-time {
    justify-content: center;
  }
}
</style>

<script>
import { timeSince } from '../date'

export default {
  props: {
    updateTime: {
      type: Object,
      default: null
    }
  },

  data() {
    return {
      now: new Date()
    }
  },

  computed: {
    updateTimeUTC() {
      return this.updateTime ? new Date(this.updateTime.UTC) : null
    },
    updateTimeNST() {
      return this.updateTime ? new Date(this.updateTime.NST) : null
    },
    updateTimeString() {
      return this.updateTimeNST
        ? this.updateTimeNST.toLocaleString() + ' NST'
        : null
    },
    updateTimeSince() {
      return timeSince(this.updateTimeUTC, this.now)
    }
  },

  created() {
    setInterval(() => (this.now = new Date()), 60 * 1000)
  }
}
</script>