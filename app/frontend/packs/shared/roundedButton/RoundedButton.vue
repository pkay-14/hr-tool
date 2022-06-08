<template>
    <button  type="button" class="v-button" @click="$emit('openPopup')">
        {{ title }}
    </button>
</template>

<script>
export default {
    name: 'RoundedButton',
    data () {
        return {
            title: 'Time off details'
        };
    },
    methods: {}

};
</script>

<style lang="scss" scoped>
.v-button {
  margin-left: 8px;
  padding: 7px 14px;
  color: #373737;
  font-size: 12px;
  font-weight: 400;
  background-color: #f1f1f1;
  border: none;
  border-radius: 42px;
  transition: 0.3s;

  &:hover, &:focus {
    color: #ffffff;
    background-color: #e7522c;
    border: none;
    text-decoration: none;
    outline: none;
  }

  &:disabled {
    color: #bababa;
    background-color: #f1f1f1;
  }
}
</style>

