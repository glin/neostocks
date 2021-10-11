<template>
  <b-navbar toggleable sticky class="header">
    <b-container class="header-container">
      <b-navbar-toggle target="nav-menu-collapse" />
      <b-navbar-brand :to="{ path: '/', query }" class="home-link p-0" aria-label="Home">
        <img class="logo" src="../../public/neostocks.png" alt> neostocks
      </b-navbar-brand>
      <b-collapse id="nav-menu-collapse" v-model="showNavMenuCollapse" class="order-2" is-nav>
        <b-navbar-nav>
          <b-nav-item :to="{ path: '/bargain', query }">Bargain</b-nav-item>
          <b-nav-item :to="{ path: '/hot', query }">Hot</b-nav-item>
          <b-nav-item :to="{ path: '/index', query }">Index</b-nav-item>
          <b-nav-item :to="{ path: '/trends' }">Trends</b-nav-item>
        </b-navbar-nav>
        <b-navbar-nav class="ml-auto mr-3">
          <SearchBar
            :value="search"
            :results="searchResults"
            :on-change="onSearchChange"
            :on-submit="onSearchSubmit"
          />
        </b-navbar-nav>
      </b-collapse>
      <div class="notifications d-flex align-self-center order-1 order-sm-last">
        <button
          ref="notificationsBtn"
          class="notifications-btn icon-btn"
          aria-label="Price alerts"
          @click="handleNotificationsBtnClick"
        >
          <BellIcon aria-hidden="true" />
        </button>
        <span v-if="showUnreadNotifications" class="unread-notifications" />
      </div>
      <b-tooltip
        :show.sync="showNotificationsTooltip"
        :disabled="isTouchCapable"
        :target="() => $refs.notificationsBtn"
        placement="bottomleft"
        title="Price Alerts"
        no-fade
      />
      <b-popover
        :target="() => $refs.notificationsBtn"
        placement="bottomleft"
        triggers="click blur"
        no-fade
        @shown="handleNotificationsShown"
      >
        <Notifications :notifications="notifications" :has-alerts-created="hasAlertsCreated" />
      </b-popover>
    </b-container>
  </b-navbar>
</template>

<script>
import { mapState, mapGetters } from 'vuex'
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
    hasAlertsCreated: {
      type: Boolean,
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
    },
    ...mapState({
      isTouchCapable: state => state.app.isTouchCapable
    }),
    ...mapGetters(['query'])
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

<style lang="scss" scoped>
@import '../assets/scss/variables';

.header {
  background-color: hsl(210, 11%, 99%);
  box-shadow: 0 2px 4px -1px hsla(0, 0%, 0%, 0.25);
}

.header-container {
  align-items: baseline;
}

@include media-breakpoint-down(xs) {
  .header-container {
    align-items: center;
  }
}

.home-link:hover {
  color: hsla(0, 0%, 0%, 0.7);
}

.logo {
  width: 25px;
  height: 25px;
}

#nav-menu-collapse {
  transition: none;
}

.nav-link {
  color: hsla(0, 0%, 0%, 0.55) !important;
}

.nav-link:hover {
  color: hsla(0, 0%, 0%, 0.8) !important;
}

.nav-link.active {
  font-weight: 600;
  color: hsla(0, 0%, 0%, 0.7) !important;
}

.notifications {
  position: relative;
}

.notifications-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
}

.unread-notifications {
  position: absolute;
  top: -1px;
  right: -2px;
  background: $dark-red;
  border-radius: 50%;
  height: 7px;
  width: 7px;
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
