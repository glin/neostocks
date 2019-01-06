<template>
  <b-list-group class="notifications-list">
    <b-list-group-item v-for="(item, index) in notifications" :key="index" :to="item.location" class="notification-item">
      <img :src="item.icon" :alt="item.ticker" class="notification-icon">
      <div>
        <div class="notification-title">{{ item.title }}</div>
        <div class="notification-message">{{ item.message }}</div>
      </div>
      <div :title="formatTimeNST(item.updateTimeNST)" class="notification-time ml-auto">{{ timeSince(item.updateTime) }}</div>
    </b-list-group-item>
    <b-list-group-item v-if="notifications.length === 0 && hasAlertsCreated" class="notification-item no-notifications">
      No alerts yet
    </b-list-group-item>
    <b-list-group-item v-if="notifications.length === 0 && !hasAlertsCreated" to="/settings" class="notification-item no-alerts-created">
      <a href="#" class="settings-link">Create a price alert</a>
    </b-list-group-item>
  </b-list-group>
</template>

<style scoped>
.notifications-list {
  width: 290px;
  max-height: 420px;
  overflow-y: auto;
  font-family: 'Open Sans', system-ui, Arial, sans-serif;
}

.notification-item {
  display: flex;
  align-items: center;
  padding: 0.5rem 0.75rem;
  min-height: 65px;
  border-radius: 0;
  border-right: none;
  border-left: none;
  border-color: #eaeaea;
}

.notification-item:first-child {
  border-top: none;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-item:hover {
  background-color: #f7f8f8;
}

.notification-item.active {
  color: #495057;
  background-color: #fff;
  border-color: #eaeaea;
}

.notification-icon {
  align-self: center;
  margin-right: 0.75rem;
  height: 35px;
}

.notification-title {
  font-size: 0.95rem;
}

.notification-time {
  font-size: 0.8rem;
  color: #999;
}

.notification-message {
  font-size: 0.8rem;
  color: #737373;
}

.no-notifications {
  display: flex;
  justify-content: center;
  height: 75px;
  font-size: 0.9rem;
  color: #737373;
}

.no-alerts-created {
  display: flex;
  justify-content: center;
  height: 75px;
}

.settings-link {
  text-decoration: none;
}
</style>

<script>
import bListGroup from 'bootstrap-vue/es/components/list-group/list-group'
import bListGroupItem from 'bootstrap-vue/es/components/list-group/list-group-item'

import { timeSince } from '../date'

export default {
  components: {
    bListGroup,
    bListGroupItem
  },

  props: {
    notifications: {
      type: Array,
      required: true
    },
    hasAlertsCreated: {
      type: Boolean,
      required: true
    }
  },

  data() {
    return {
      now: new Date()
    }
  },

  created() {
    setInterval(() => (this.now = new Date()), 60 * 1000)
  },

  methods: {
    timeSince(time) {
      return timeSince(new Date(time), this.now)
    },
    formatTimeNST(time) {
      return new Date(time).toLocaleString() + ' NST'
    }
  }
}
</script>