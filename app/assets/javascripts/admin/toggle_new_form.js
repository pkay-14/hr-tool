(function() {

  function showNewForm(openControl, form) {
    openControl.on('click', function(e) {
      e.preventDefault();
      openControl.parent().addClass('hide');
      form.removeClass('hide');
    });
  }

  function hideNewForm(closeControl, form, openControl) {
    closeControl.on('click', function(e) {
      var isLink = e.target.tagName.toLowerCase() === 'a';
      if (isLink) {
        e.preventDefault();
      }
      form.addClass('hide');
      openControl.parent().removeClass('hide');
    });
  }

  function initToggleNewForm() {
    var openFormBtn = $('[data-open-new-form]');
    var closeFormBtn = $('[data-hide-new-form]');
    var newForm = $('[data-new-form]');

    showNewForm(openFormBtn, newForm);
    hideNewForm(closeFormBtn, newForm, openFormBtn);
  }


  $(document).on('page:load', initToggleNewForm).ready(initToggleNewForm);
}).call(this);