<template>
  <b-navbar toggleable fixed="top" variant="light" type="light" class="header">
    <b-container>
      <b-navbar-toggle target="nav-menu-collapse" />
      <b-navbar-brand :to="{ path: '/', query }" class="brand">
        <img class="logo" src="../assets/neostocks.png" alt="neostocks-logo"> neostocks
      </b-navbar-brand>
      <b-collapse id="nav-menu-collapse" v-model="showNavMenuCollapse" is-nav>
        <b-navbar-nav>
          <b-nav-item :to="{ path: '/bargain', query }">Bargain</b-nav-item>
          <b-nav-item :to="{ path: '/hot', query }">Hot</b-nav-item>
          <b-nav-item :to="{ path: '/index', query }">Index</b-nav-item>
        </b-navbar-nav>
        <b-navbar-nav class="ml-auto">
          <SearchBar :value="search" :results="searchResults" :on-change="onSearchChange" :on-submit="onSearchSubmit" />
          <div class="notifications">
            <button id="notifications-btn" class="icon-btn" @click="handleNotificationsBtnClick">
              <BellIcon />
            </button>
            <span v-if="showUnreadNotifications" class="unread-notifications">●</span>
          </div>
          <b-tooltip :show.sync="showNotificationsTooltip" target="notifications-btn" placement="bottomleft" title="Notifications" no-fade />
          <b-popover target="notifications-btn" placement="bottomleft" triggers="click blur" no-fade @shown="handleNotificationsShown">
            <div class="notifications-heading">
              <div class="notifications-title">
                Notifications
              </div>
              <b-link id="settings-btn" :to="'/settings'" class="icon-btn">
                <SettingsIcon />
              </b-link>
              <b-tooltip target="settings-btn" placement="bottomleft" triggers="hover" title="Settings" no-fade />
            </div>
            <Notifications :notifications="notifications" />
          </b-popover>
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

.notifications {
  display: flex;
  position: relative;
}

#notifications-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 0 0 16px;
}

@media (max-width: 575.98px) {
  #notifications-btn {
    display: none;
  }
}

.unread-notifications {
  position: absolute;
  top: -4px;
  right: -3px;
  color: #dc3545;
  /* color: #e36209; */
}

.notifications-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid #eee;
  background-color: #f3f3f3;
  font-family: 'Open Sans';
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
</style>

<style>
.tooltip {
  font-family: 'Open Sans';
  font-size: 0.825rem;
}

.tooltip-inner {
  padding: 0.3rem 0.6rem;
}

.popover {
  max-width: 100%;
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.15);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.popover-body {
  padding: 0;
}
</style>

<script>
import SearchBar from './SearchBar'
import Notifications from './Notifications'
import BellIcon from '@mdi/svg/svg/bell-outline.svg'
import SettingsIcon from '@mdi/svg/svg/settings-outline.svg'

export default {
  components: {
    SearchBar,
    Notifications,
    BellIcon,
    SettingsIcon
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
    notifications: {
      type: Array,
      required: true
    },
    onNotificationsRead: {
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
      showNavMenuCollapse: false,
      showNotificationsTooltip: false
    }
  },

  computed: {
    showUnreadNotifications() {
      return this.notifications.some(item => !item.isRead)
    }
  },

  watch: {
    $route() {
      this.showNavMenuCollapse = false
    }
  },

  methods: {
    handleNotificationsBtnClick() {
      this.showNotificationsTooltip = false
    },
    handleNotificationsShown() {
      this.onNotificationsRead()
    }
  }
}
</script>