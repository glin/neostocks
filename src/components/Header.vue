<template>
  <b-navbar toggleable fixed="top" variant="light" type="light" class="header">
    <b-container>
      <b-navbar-toggle target="nav-menu-collapse" />
      <b-navbar-brand :to="{ path: '/', query }" class="brand">
        <img class="logo" src="../assets/neostocks.png" alt="neostocks-logo"> neostocks
      </b-navbar-brand>
      <b-collapse id="nav-menu-collapse" v-model="showNavMenuCollapse" class="order-2" is-nav>
        <b-navbar-nav>
          <b-nav-item :to="{ path: '/bargain', query }">Bargain</b-nav-item>
          <b-nav-item :to="{ path: '/hot', query }">Hot</b-nav-item>
          <b-nav-item :to="{ path: '/index', query }">Index</b-nav-item>
        </b-navbar-nav>
        <b-navbar-nav class="ml-auto mr-3">
          <SearchBar :value="search" :results="searchResults" :on-change="onSearchChange" :on-submit="onSearchSubmit" />
        </b-navbar-nav>
      </b-collapse>
      <div class="order-1 order-sm-last">
        <button ref="notificationsBtn" class="notifications-btn icon-btn" @click="handleNotificationsBtnClick">
          <BellIcon />
        </button>
        <span v-if="showUnreadNotifications" class="unread-notifications">●</span>
        <b-tooltip :show.sync="showNotificationsTooltip" :target="() => $refs.notificationsBtn" placement="bottomleft" title="Notifications" no-fade />
        <b-popover :target="() => $refs.notificationsBtn" placement="bottomleft" triggers="click blur" no-fade @shown="handleNotificationsShown">
          <Notifications :notifications="notifications" />
        </b-popover>
      </div>
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

.notifications-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
}

.unread-notifications {
  position: absolute;
  top: -3px;
  right: -3px;
  color: #dc3545;
  /* color: #e36209; */
  font-family: Arial;
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
  overflow: hidden;
  border-radius: 0.3rem;
}

.popover .arrow::before {
  border-bottom-color: rgba(0, 0, 0, 0.1);
}

.popover .arrow::after {
  border-bottom-color: #f3f3f3;
}
</style>

<script>
import bCollapse from 'bootstrap-vue/es/components/collapse/collapse'
import bContainer from 'bootstrap-vue/es/components/layout/container'
import bNavItem from 'bootstrap-vue/es/components/nav/nav-item'
import bNavbar from 'bootstrap-vue/es/components/navbar/navbar'
import bNavbarBrand from 'bootstrap-vue/es/components/navbar/navbar-brand'
import bNavbarNav from 'bootstrap-vue/es/components/navbar/navbar-nav'
import bNavbarToggle from 'bootstrap-vue/es/components/navbar/navbar-toggle'
import bPopover from 'bootstrap-vue/es/components/popover/popover'
import bTooltip from 'bootstrap-vue/es/components/tooltip/tooltip'

import BellIcon from '@mdi/svg/svg/bell-outline.svg'

import SearchBar from './SearchBar'
import Notifications from './Notifications'

export default {
  components: {
    bCollapse,
    bContainer,
    bNavItem,
    bNavbar,
    bNavbarBrand,
    bNavbarNav,
    bNavbarToggle,
    bPopover,
    bTooltip,
    BellIcon,
    SearchBar,
    Notifications
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