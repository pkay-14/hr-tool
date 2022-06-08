import Vue from 'vue';
import AdminApp from '@/admin/AdminApp';
import '@styles/admin/admin.scss';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('hello'));
  const app = new Vue({
    // this is the css-selector of the element, where this compiled Vue app
    // will be rendered
    el: '#vue-app',
    render: (h) => h(AdminApp)
  });

  // eslint-disable-next-line no-console
  console.log(app);
});
