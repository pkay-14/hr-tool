import axios from 'axios';

(function setupAxios() {
  const tokenDomElement = document.querySelector('meta[name="csrf-token"]');

  if (tokenDomElement) {
    axios.defaults.headers.common['X-CSRF-Token'] = tokenDomElement.content;
  }

  window.axios = axios;
})();
