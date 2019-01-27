<template>
  <div>
    <div class="notifications-heading">
      <div class="notifications-title">Price Alerts</div>
      <b-link ref="settingsBtn" :to="'/settings'" class="icon-btn" aria-label="Settings">
        <SettingsIcon class="settings-icon" aria-hidden="true" />
      </b-link>
      <b-tooltip
        :target="() => $refs.settingsBtn"
        :disabled="isTouchCapable"
        placement="bottomleft"
        triggers="hover"
        title="Settings"
        no-fade
      />
    </div>
    <NotificationsList :notifications="notifications" :has-alerts-created="hasAlertsCreated" />
  </div>
</template>

<script>
import { mapState } from 'vuex'
import bLink from 'bootstrap-vue/es/components/link/link'
import bPopover from 'bootstrap-vue/es/components/popover/popover'
import bTooltip from 'bootstrap-vue/es/components/tooltip/tooltip'

import SettingsIcon from '@mdi/svg/svg/settings-outline.svg'

import NotificationsList from './NotificationsList'

export default {
  components: {
    bLink,
    bPopover,
    bTooltip,
    SettingsIcon,
    NotificationsList
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

  computed: {
    ...mapState({
      isTouchCapable: state => state.app.isTouchCapable
    })
  }
}
</script>

<style>
.tooltip {
  font-family: 'Open Sans', system-ui, Arial, sans-serif;
}

.tooltip-inner {
  padding: 0.3rem 0.6rem;
}
</style>

<style scoped>
.notifications-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid #eee;
  background-color: #f3f3f3;
  font-family: 'Open Sans', system-ui, Arial, sans-serif;
}

.notifications-title {
  font-size: 0.95rem;
  font-weight: 600;
}

.icon-btn {
  border: none;
  outline: none;
  background-color: transparent;
  opacity: 0.5;
  cursor: pointer;
}

.icon-btn:hover {
  opacity: 0.65;
}

.icon-btn:active {
  opacity: 1;
}

.settings-icon {
  display: block;
}
</style>