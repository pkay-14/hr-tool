<template>
  <div>
    <p class="message">
      {{ message }}
      <span class="messageUppercased">
        {{ message.toUpperCase() }}
      </span>
    </p>
  </div>
</template>

<script>
export default {
  name: 'AdminApp',
  data() {
    return {
      message: 'Hello from Vue!'
    };
  }
};


window.showVue = () => document.querySelector('.message').style.display = 'block';
</script>

<style lang="scss" scoped>
.message {
  position: absolute;
  display: none;
  z-index: 100;
  top: 50%;
  right: 50%;
  background-color: #ff0000;
}
</style>

<style lang="scss" scoped src="../../styles/admin/admin.scss"></style>
