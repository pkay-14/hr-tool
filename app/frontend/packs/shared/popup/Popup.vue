<template>
    <div class="v-popup__container">
        <div class="v-overlay" @click="$emit('closePopup')" />
        <div class="v-popup">
            <div class="v-popup__header">
                {{ title }}
                <i class="btn-icon cancel-icon" @click="$emit('closePopup')" />
            </div>
            <div class="v-popup__body">
                <slot />
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'Popup',
    props: {
        title: {
            type: String,
            required: true
        }
    },
    methods: {}
};
</script>

<style lang="scss" scoped>
.v-popup__container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  z-index: 10;
}

.v-overlay {
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.75);
  z-index: 11;
}

.v-popup {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  min-width: 465px;
  z-index: 12;
}

.v-popup__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 22px;
  padding: 9px 15px;
  background: #F1F1F1;
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;
}

.v-popup__body {
  margin-top: -1px;
  padding: 25px 15px 15px 15px;
  background: #FFFFFF;
  border-bottom-left-radius: 8px;
  border-bottom-right-radius: 8px;
}

.v-popup__text {
  width: 230px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 14px;
  span {
    width: 10%;
  }
}

.v-block--calculate {
  width: 125px;
  display: flex;
  flex-direction: column;
  margin: 0 0 20px 0;
  span {
    font-size: 12px;
    color: #BABABA;
    margin-bottom: 5px;
  }
}

.v-popup__buttons {
  display: flex;
  justify-content: center;
  margin-top: 40px;
}

.v-popup__date {
  width: 121px;
  height: 30px;
}

@media (max-width: 576px) {
  .v-popup {
    width: 90%;
    min-width: unset;
  }
}
</style>

