<template>
    <div class="v-container" @keydown.esc="closePopup">
        <RoundedButton @openPopup='openPopup' />
        <Popup v-if='isOpen'
               :title="title"
               @closePopup='closePopup'
        >
            <!--            <p class="v-popup__text">-->
            <!--                Entitlement per year-->
            <!--                <span>-->
            <!--                    {{ entitlement_per_year }}-->
            <!--                </span>-->
            <!--            </p>-->
            <div class="v-block--calculate">
                <span>Calculate on date</span>
                <Datepicker :value="dateVal"
                            @input="postDateValue"
                />

            </div>
            <p class="v-popup__text bold-text">
                Vacation days available<span>{{ days_available }}</span>
            </p>
            <div class="v-popup__buttons">
                <button type="button" class="mm-button mm-button-orange" @click="closePopup">
                    Ok
                </button>
            </div>
        </Popup>
    </div>
</template>

<script>
import Datepicker from '../shared/datepicker/Datepicker';
import RoundedButton from '../shared/roundedButton/RoundedButton';
import Popup from '../shared/popup/Popup';

const masterId = document.querySelector('#master-title').getAttribute('data-master-id');
//const entitlementPerYear = document.querySelector('#mm-days__list').getAttribute('data-per-year');

export default {
    name: 'TimeOffDetails',
    components: {
        RoundedButton,
        Popup,
        Datepicker
    },

    data () {
        return {
            message: 'Hello',
            isOpen: false,
            title: 'Time Off details',
            dateVal: '',
            days_available: '0.0'
            //entitlement_per_year: entitlementPerYear
        };
    },
    methods: {
        openPopup() {
            this.isOpen = true;
        },

        closePopup() {
            this.isOpen = false;
            this.days_available = '0.0';
        },

        addCsrfTokenToRequestHeaders(requestHeaders) {
            const tokenDomElement = document.querySelector('meta[name="csrf-token"]');

            if (tokenDomElement) {
                requestHeaders.append('X-CSRF-Token', tokenDomElement.content);
                requestHeaders.append('Content-Type', 'application/json');
            }

            return requestHeaders;
        },

        postDateValue(dateValue) {
            this.dateVal = new Date(dateValue);

            fetch('/api/v1/vacations/vacation_details', {
                method: 'POST',
                headers: this.addCsrfTokenToRequestHeaders(new Headers()),
                body: JSON.stringify({
                    date: this.dateVal,
                    master_id: masterId
                })
            }).then(response => response.json()).then(response => {
                this.days_available = response.days_available.toFixed(1);
                //this.entitlement_per_year = response.entitlement_per_year.toFixed(1);
            });
        }
    }
};
</script>


