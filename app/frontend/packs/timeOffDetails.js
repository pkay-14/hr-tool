import Vue from 'vue';
import TimeOffDetails from './timeOffDetails/TimeOffDetails';

document.addEventListener('DOMContentLoaded', () => {
  const timeOffDetails = new Vue({
    el: '#vue-time-off-details',
    render: (h) => h(TimeOffDetails)
  });
});
