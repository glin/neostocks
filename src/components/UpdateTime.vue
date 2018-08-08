<template>
  <b-container class="update-time">
    <div v-if="updateTimeString" :title="updateTimeString">
      last updated {{ updateTimeSince }} ago
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