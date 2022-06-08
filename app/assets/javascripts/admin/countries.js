(function () {
  function addNumberValidationForVacationDaysInput() {
    const vacationDaysPerYearElement = document.querySelector('#country_vacation_days_per_year');
    const sickDaysPerYearElement = document.querySelector('#country_sick_days_per_year');

    if (vacationDaysPerYearElement && sickDaysPerYearElement) {
      window.addNumberValidationForInputField(vacationDaysPerYearElement, 1);
      window.addNumberValidationForInputField(sickDaysPerYearElement, 1);
    }
  }

  function ready() {
    $('#holidays').on('cocoon:after-insert', function (e, insertedItem) {
      $('.input-append.date').datetimepicker();
    });

    $('#holiday_year').change(function () {
      $(this).find('option:selected').each(function () {
        var optionValue = $(this).attr('value');

        if (optionValue) {
          $('.holiday').not(`.${optionValue}`).hide();
          $(`.${optionValue}`).show();
        } else {
          $('.holiday').hide();
        }
      });
    }).change();

    addNumberValidationForVacationDaysInput();
  }

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();