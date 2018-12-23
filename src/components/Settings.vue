<template>
  <Card class="settings">
    <h1 class="title">Settings</h1>

    <div class="settings-section">
      <h2 class="settings-heading d-none d-sm-block">Desktop Notifications</h2>
      <h2 class="settings-heading d-block d-sm-none">Browser Notifications</h2>
      <div class="toggle-group">
        <label class="toggle-label">
          <toggle-button :value="settings.enableDesktopNotifications" :sync="true" :width="48" class="settings-toggle" color="#007bff" @click.native.stop.prevent="handleDesktopNotificationsChange" />
          <span v-if="!notificationsBlocked">
            {{ settings.enableDesktopNotifications ? 'Enabled' : 'Disabled' }}
          </span>
          <span v-else>
            Blocked
            <span class="notifications-blocked">(allow via browser settings)</span>
          </span>
        </label>
      </div>
    </div>

    <div class="settings-section alerts-section">
      <div class="alerts-header">
        <h2 class="settings-heading">Price Alerts</h2>
        <a href="#" class="new-alert-btn" @click.prevent="handleCreateAlert('above')">New alert</a>
      </div>

      <b-list-group>
        <b-list-group-item v-if="settings.alerts.length === 0" class="alerts-list-item no-alerts pl-1">
          No alerts
        </b-list-group-item>
        <b-list-group-item v-for="(alert, i) in settings.alerts" :key="i" class="alerts-list-item pl-2">
          <b-col>
            <b-row class="mb-2">
              <label class="mr-3">
                <div class="settings-label">Condition</div>
                <b-form-select :value="alert.condition" class="settings-select" @change="condition => handleAlertChange(i, { condition })">
                  <option value="above">price above</option>
                  <option value="between">price between</option>
                  <option value="exact">price exactly</option>
                  <option value="high">new high</option>
                </b-form-select>
              </label>
              <label v-if="alert.condition === 'exact'" class="mr-3">
                <div class="settings-label">Price</div>
                <b-form-input :value="alert.exactPrice" class="settings-input" type="number" min="0" @input="exactPrice => handleAlertChange(i, { exactPrice })" />
              </label>
              <label v-if="['above', 'between'].includes(alert.condition)" class=" mr-3">
                <div class="settings-label">Min Price</div>
                <b-form-input :value="alert.minPrice" class="settings-input" type="number" min="0" @input="minPrice => handleAlertChange(i, { minPrice })" />
              </label>
              <label v-if="['below', 'between'].includes(alert.condition)">
                <div class="settings-label">Max Price</div>
                <b-form-input :value="alert.maxPrice" class="settings-input" type="number" min="0" @input="maxPrice => handleAlertChange(i, { maxPrice })" />
              </label>
              <label v-if="alert.condition === 'high'">
                <div class="settings-label">Time Period</div>
                <b-form-select :value="alert.highPeriod" class="settings-select" @change="highPeriod => handleAlertChange(i, { highPeriod })">
                  <option value="1d">1 day</option>
                  <option value="5d">5 day</option>
                  <option value="1m">1 month</option>
                  <option value="all">all-time</option>
                </b-form-select>
              </label>
            </b-row>

            <b-row class="mb-3">
              <label class="settings-label">Tickers</label>
              <Multiselect :value="alert.includeTickers" :options="tickers" :close-on-select="false" :placeholder="(alert.includeTickers && alert.includeTickers.length > 0) ? '' : 'all tickers'" class="settings-multiselect" multiple hide-selected preserve-search select-label="" @input="includeTickers => handleAlertChange(i, { includeTickers })">
                <template slot="option" slot-scope="props">
                  <div class="d-flex align-items-center">
                    <img v-if="companies[props.option]" :src="companies[props.option].logo" :alt="props.option" class="company-logo">
                    {{ props.option }}
                  </div>
                </template>
                <template slot="noResult"><span class="no-results">No results found</span></template>
              </Multiselect>
            </b-row>
          </b-col>

          <button :id="`delete-btn-${i}`" type="button" class="close delete-btn d-sm-none d-block" @click="handleDeleteAlert(i)">
            <span aria-hidden="true">&times;</span>
          </button>
          <b-tooltip :target="`delete-btn-${i}`" placement="bottomleft" title="Remove alert" delay="700" no-fade />
        </b-list-group-item>
      </b-list-group>
    </div>
  </Card>
</template>

<style scoped>
.settings {
  padding: 20px 25px 20px;
}

.title {
  margin-bottom: 1.5rem;
  font-size: 1.25rem;
  color: #555;
}

.settings-section:not(:first-of-type) {
  margin-top: 2rem;
}

.settings-heading {
  font-weight: 600;
  font-size: 1rem;
  line-height: 1.5rem;
}

.toggle-group {
  display: inline-block;
}

.toggle-label {
  display: flex;
  margin-bottom: 0;
  cursor: pointer;
}

.settings-toggle {
  margin-right: 0.75rem;
}

.notifications-blocked {
  margin-left: 0.4rem;
  font-size: 0.8rem;
  color: #6c757d;
}

.alerts-section {
  max-width: 440px;
}

.alerts-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.alerts-list-item {
  display: flex;
  border-left: none;
  border-right: none;
  border-bottom: none;
}

.alerts-list-item:hover {
  /* Prevent borders from disappearing */
  z-index: inherit;
}

.delete-btn {
  align-self: flex-start;
}

.alerts-list-item:hover .delete-btn {
  display: block !important;
}

.icon-btn {
  display: flex;
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

.new-alert-btn {
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
  font-weight: 600;
  text-decoration: none;
}

.new-alert-btn:active {
  color: #003c7d;
}

.no-alerts {
  font-size: 0.95rem;
  color: #737373;
}

.settings-label {
  margin-bottom: 0.4rem;
  font-size: 0.85rem;
  letter-spacing: 0.25px;
  color: #555;
}

.settings-select {
  border: 1px solid #dee2e6;
  transition: none;
}

.settings-select:focus {
  box-shadow: 0 0 0 1px rgba(0, 123, 255, 0.45);
}

.settings-input {
  width: 100px;
  border: 1px solid #dee2e6;
  transition: none;
}

.settings-input:focus {
  box-shadow: 0 0 0 1px rgba(0, 123, 255, 0.45);
}

.company-logo {
  margin-right: 10px;
  height: 25px;
}

.settings-multiselect {
  width: 380px;
}

.no-results {
  font-size: 0.95rem;
  color: #737373;
}
</style>

<style>
.multiselect__tag {
  background: #dfe8ef;
  color: #2a2a2c;
}

.multiselect__tag-icon:after {
  color: #2a2a2c;
}

.multiselect__tag-icon:focus,
.multiselect__tag-icon:hover {
  background: #c0d1df;
}

.multiselect__tag-icon:focus:after,
.multiselect__tag-icon:hover:after {
  color: #2a2a2c;
}

.multiselect__option {
  color: inherit;
}

.multiselect__option--highlight,
.multiselect__option--highlight:after {
  background: #efefef;
}
</style>

<script>
import bCol from 'bootstrap-vue/es/components/layout/col'
import bRow from 'bootstrap-vue/es/components/layout/row'
import bFormSelect from 'bootstrap-vue/es/components/form-select/form-select'
import bFormInput from 'bootstrap-vue/es/components/form-input/form-input'
import bListGroup from 'bootstrap-vue/es/components/list-group/list-group'
import bListGroupItem from 'bootstrap-vue/es/components/list-group/list-group-item'
import bTooltip from 'bootstrap-vue/es/components/tooltip/tooltip'

import Vue from 'vue'
import ToggleButton from 'vue-js-toggle-button'
import Multiselect from 'vue-multiselect'
import 'vue-multiselect/dist/vue-multiselect.min.css'

import Card from './Card'
import companies from '../companies'
import { notificationsBlocked } from '../notifications'

Vue.use(ToggleButton)

export default {
  components: {
    bCol,
    bRow,
    bFormSelect,
    bFormInput,
    bListGroup,
    bListGroupItem,
    bTooltip,
    Card,
    Multiselect
  },

  props: {
    settings: {
      type: Object,
      required: true
    },
    onSettingsChange: {
      type: Function,
      required: true
    }
  },

  data() {
    return {
      tickers: Object.keys(companies).filter(ticker => ticker !== 'NEODAQ'),
      companies
    }
  },

  computed: {
    notificationsBlocked() {
      // Update on changes from Disabled -> Blocked
      return !this.settings.enableDesktopNotifications && notificationsBlocked()
    }
  },

  methods: {
    handleDesktopNotificationsChange() {
      this.onSettingsChange({
        enableDesktopNotifications: !this.settings.enableDesktopNotifications
      })
    },
    handleCreateAlert(condition) {
      const newAlerts = this.settings.alerts.concat({ condition })
      this.onSettingsChange({ alerts: newAlerts })
    },
    handleDeleteAlert(index) {
      const newAlerts = this.settings.alerts.filter((item, i) => i !== index)
      this.onSettingsChange({ alerts: newAlerts })
    },
    handleAlertChange(index, value) {
      if (value.condition) {
        const conditionDefaults = {
          high: { highPeriod: '1d', minPrice: null, maxPrice: null, exactPrice: null },
          above: { highPeriod: null, maxPrice: null, exactPrice: null },
          between: { highPeriod: null, exactPrice: null },
          exact: { highPeriod: null, minPrice: null, maxPrice: null }
        }
        value = { ...value, ...conditionDefaults[value.condition] }
      }

      if (value.minPrice != null) {
        value.minPrice = this.parseInt(value.minPrice)
      }
      if (value.maxPrice != null) {
        value.maxPrice = this.parseInt(value.maxPrice)
      }
      if (value.exactPrice != null) {
        value.exactPrice = this.parseInt(value.exactPrice)
      }

      const newAlerts = this.settings.alerts.map((item, i) => {
        if (i !== index) return item
        return { ...item, ...value }
      })
      this.onSettingsChange({ alerts: newAlerts })
    },
    parseInt(value) {
      return value !== '' ? parseInt(value) : null
    }
  }
}
</script>