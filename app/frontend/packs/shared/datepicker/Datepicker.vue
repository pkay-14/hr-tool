<template>
    <VueJsDatepicker
        class="vue-js-datepicker-container"

        :id="id"
        :name="name"

        :disabled="disabled"
        :format="format"

        :maximum-view="maximumView"
        :minimum-view="minimumView"

        :monday-first="true"

        :required="required"
        :typeable="false"
        :use-utc="false"
        :full-month-name="true"

        :calendar-button="true"
        calendar-button-icon="datepicker--icon-calendar"

        :clear-button="false"
        clear-button-icon=""

        :placeholder="placeHolder"

        @opened="$emit('opened')"
        @closed="$emit('closed')"
        @selected="$emit('selected', $event)"
        @selectedDisabled="$emit('selectedDisabled', $event)"
        @input="$emit('input', $event)"
        @cleared="$emit('cleared')"
    />
</template>

<script>
import Datepicker from 'vuejs-datepicker';

export default {
    name: 'Datepicker',

    components: {
        VueJsDatepicker: Datepicker
    },

    props: {
        id: {
            type: String,
            required: false,
            default: undefined
        },
        name: {
            type: String,
            required: false,
            default: undefined
        },
        placeHolder: {
            type: String,
            required: false,
            default: ''
        },
        format: {
            type: String,
            required: false,
            default: 'dd.MM.yyyy'
        },
        minimumView: {
            type: String,
            required: false,
            default: 'day'
        },
        maximumView: {
            type: String,
            required: false,
            default: 'month'
        },
        disabled: {
            type: Boolean,
            required: false,
            default: false
        },
        required: {
            type: Boolean,
            required: false,
            default: false
        },
        typeable: {
            type: Boolean,
            required: false,
            default: true
        }
    },

    data() {
        return {};
    },

    methods: {}
};
</script>

<style scoped>
/*  root container class */

.vue-js-datepicker-container::v-deep > :first-child {
  width: auto;
  height: 100%;
  min-height: 38px;

  display: grid;
  grid-template-columns: 1fr;
  grid-auto-columns: 25px;

  border: 1px solid #F1F1F1;
  border-radius: 4px;
}

/*  input container class */
.vue-js-datepicker-container::v-deep > :first-child > input {
  width: 100%;
  height: 38px;
  margin: 0;
  grid-column: 1/2;
  grid-row: 1;
  background-color: #FFFFFF;
  border: none;
  box-shadow: none;
}

/*  icon container class */
.vue-js-datepicker-container::v-deep > :first-child > span {
  grid-row: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  border: 1px solid #ccc;
  border-left: none;
  /*background: url("data:image/svg+xml,%3Csvg width='12' height='14' viewBox='0 0 12 14' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath fill-rule='evenodd' clip-rule='evenodd' d='M10.2 1.2H10.8C11.46 1.2 12 1.74 12 2.4V12C12 12.66 11.46 13.2 10.8 13.2H1.2C0.54 13.2 0 12.66 0 12V2.4C0 1.74 0.54 1.2 1.2 1.2H1.8V0H3V1.2H9V0H10.2V1.2ZM1.2 12H10.8V4.2H1.2V12ZM3 6H4.2V7.2H3V6ZM3 8.39999H4.2V9.59999H3V8.39999ZM6.60003 6H5.40003V7.2H6.60003V6ZM5.40003 8.39999H6.60003V9.59999H5.40003V8.39999ZM9.00001 6H7.80001V7.2H9.00001V6ZM7.80001 8.39999H9.00001V9.59999H7.80001V8.39999Z' fill='%23BABABA'/%3E%3C/svg%3E") no-repeat center;*/
  background: #eee;
}

/*round right borders for last element*/
.vue-js-datepicker-container::v-deep > :first-child > span:last-of-type {
  border-radius: 0 4px 4px 0;
}

/*selected calendar item style*/
/*selectors 'cell' and 'selected' are using in inner component */
.vue-js-datepicker-container::v-deep > :not(:first-child) span.cell.selected {
  background: #FD5D32;
  font-weight: 400;
}

/*selectors 'cell', 'day', 'month' and 'year' are using in inner component */
.vue-js-datepicker-container.vue-js-datepicker-container::v-deep > :not(:first-child) span:not(.blank).cell.day:hover,
.vue-js-datepicker-container.vue-js-datepicker-container::v-deep > :not(:first-child) span.cell.month:hover,
.vue-js-datepicker-container.vue-js-datepicker-container::v-deep > :not(:first-child) span.cell.year:hover {
  border-color: #FD5D32;
}

.vue-js-datepicker-container::v-deep > :first-child > .vdp-datepicker__calendar-button {
  background-color: #FFFFFF;
  border: none;
}
</style>
