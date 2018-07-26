<template>
  <b-container class="footer">
    <div v-if="updateTimeString" :title="updateTimeString" class="last-update-time">
      last updated {{ updateTimeSince }} ago
    </div>
  </b-container>
</template>

<style scoped>
.footer {
  padding: 6px 2px;
}

.last-update-time {
  margin-right: 2px;
  text-align: right;
  font-style: italic;
  font-size: small;
}
</style>

<script>
export default {
  props: {
    updateTime: {
      type: String,
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

function timeSince(then, now = new Date()) {
  var seconds = Math.floor((now - then) / 1000)

  var interval = Math.floor(seconds / 3600)
  if (interval > 1) {
    return interval + ' hours'
  }
  interval = Math.floor(seconds / 60)
  if (interval > 1) {
    return interval + ' mins'
  } else if (interval === 1) {
    return interval + ' min'
  }
  return 'less than 1 min'
}
</script>