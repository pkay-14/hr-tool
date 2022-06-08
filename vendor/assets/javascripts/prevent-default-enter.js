/**
 * @description This function prevents the form from being submitted when you press on the enter button
 * @example window.onKeydownPreventDefaultEnter(someForm)
 * @param {HTMLElement} form element. Example: const someForm = document.querySelector('#some-form')
 */

function onKeydownPreventDefaultEnter(form) {
  if (!form) return;

  form.addEventListener('keydown', event => {
    if (event.code === 'Enter' || event.code === 'NumpadEnter') {
      event.preventDefault();
      return false;
    }
  });
}
