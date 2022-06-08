/**
 * @description This function opens and closes the popup
 * @example window.openPopup(popupSelector). For closing popup add [data-close-popup] selector
 * @param {String} popupSelector element. Example: window.openPopup('#popup')
 */

(function () {
  function hidePopup(popupSelector) {
    const popupEl = document.querySelector(popupSelector);
    const overlayEl = document.querySelector('.mm-background-overlay');

    popupEl.style.display = 'none';
    overlayEl.style.display = 'none';
  }

  function hidePopupOnEscapeKey(event, popupSelector) {
    if (event.key === 'Escape') hidePopup(popupSelector)
  }

  function openPopup(popupSelector) {
    const popupEl = document.querySelector(popupSelector);
    const overlayEl = document.querySelector('.mm-background-overlay');
    const closeModalEls = popupEl.querySelectorAll('[data-close-popup]');

    popupEl.style.display = 'block';
    overlayEl.style.display = 'block';


    closeModalEls.forEach(closeBtn => {
      closeBtn.addEventListener('click', () => hidePopup(popupSelector));
      overlayEl.addEventListener('click', () => hidePopup(popupSelector))
      document.addEventListener('keydown', () => hidePopupOnEscapeKey(event, popupSelector));
    });
  }

  window.openPopup = openPopup;
}())
