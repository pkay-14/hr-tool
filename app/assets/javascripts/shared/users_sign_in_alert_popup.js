(function () {
  function addHandlerForLoginFlashAlert() {
    const closeButtons = document.querySelectorAll(".close--button");
    closeButtons.forEach(container => container.addEventListener('click', event => {
        const container = event.currentTarget.parentElement;
        if (container) {
          container.style.display = 'none';
        }
      })
    );
  }

  if (location.pathname.match(/^.*(\/users\/sign_in)(\/?|\?.*)$/i)) {
    window.addEventListener('load', addHandlerForLoginFlashAlert);
  }
}());
