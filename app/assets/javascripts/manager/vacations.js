(function() {
  var totalVacationDays = 0;
  var totalSickDays = 0;
  var vacationType = 'vacation';
  var isWorkingDaysError = false;
  var isTotalDaysError = false;
  var isDuplicate = false;

  function vacations_ready() {
    initExportLogic();
    resetVacationsInfo();
    vacations_ajax_filters();
    onEmployeeChange();
    onDateInputChange();
    onDatePickerChange();
    onVacationTypeChange();
    onHalfDayChecboxChange();
    onNotPaidDaysCheckboxChange();
    addListenerToTimeOffButtons();
    requestOpenModal();
    attachHandlersToAddVacationBtnClick();

    $('.open-request-form').on('click', function() {
      $(this).parent().addClass('hide');
      $('.vacation-request-form').removeClass('hide');
      initiateSelect2();
      totalVacationDays = Number($('#past').html()) + Number($('#current').html());
      totalSickDays = Number($('[data-total-sick-days]').html());
      return false;
    });

    $('.cancel-adding').on('click', function() {
      $('.open-request-form').parent().removeClass('hide');
      $('.vacation-request-form').addClass('hide');
      return false;
    });

    $('[data-hint]').popover({
      trigger: 'hover',
      placement: 'bottom'
    });
  }

  function initiateSelect2() {
    var select2El = $('.select2-js');

    if (select2El.length) {
      select2El.select2({
        dropdownParent: $('#eployeeSelectParent'),
        width: '100%'
      });
    }
  }

  function vacations_ajax_filters() {
    $('#vacations .search-form input').on('input', function(e) {
      e.preventDefault();
      if ($(this).val().length > 2 || $(this).val().length === 0) {
        var filters = gather_vacations_filters();

        $.ajax({
          url: '/manager/vacations/search',
          type: 'GET',
          data: filters
        });
      }
    });


    if (location.pathname.includes('manager/vacations')) {
      function getDateRequest(date) {
        date.datetimepicker({
          pickTime: false
        }).on('changeDate', function () {
          var filters = gather_vacations_filters();
          const queryString = window.location.search;

          $.ajax({
            url: `/manager/vacations/search${queryString}`,
            type: 'GET',
            data: filters
          });
        });
      }

      getDateRequest($('[data-datepicker-days-off-to]'));
      getDateRequest($('[data-datepicker-days-off-from]'));
    }

    $('#vacation-status-filter li, #vacation-type-filter li, #vacation-project-filter li').bind('click', function(e) {
      var toggleLink;

      e.preventDefault();
      var self = $(this);

      self.parent().find('.hide').removeClass('hide');
      self.addClass('hide');

      if (self.is('[data-category]')) {
        toggleLink = $('[data-current-category]');
        toggleLink.attr('data-current-category', self.attr('data-category'));
      } else if (self.is('[data-status]')) {
        toggleLink = $('[data-current-status]');
        toggleLink.attr('data-current-status', self.attr('data-status'));
      } else if (self.is('[data-project]')) {
        toggleLink = $('[data-current-project]');
        toggleLink.attr('data-current-project', self.attr('data-project'));
      }
      toggleLink.text(self.text());

      var filters = gather_vacations_filters();
      var urlParam = getUrlParameter('master') ? '?master=true' : '';

      $.ajax({
        url: `/manager/vacations/search${urlParam}`,
        type: 'GET',
        data: filters
      });
    });
  }

  function gather_vacations_filters() {
    return {
      status: $('[data-current-status]').attr('data-current-status'),
      query: $('#vacations .search-form input').val(),
      category: $('[data-current-category]').attr('data-current-category'),
      project: $('[data-current-project]').attr('data-current-project'),
      filter_start_date: $('#time-off-from-date').val().toString(),
      filter_end_date: $('#time-off-to-date').val().toString(),
      per_page: $('#per_page').val()
    };
  }

  function load_vacation_days() {
    var data = { vacation: {} };
    var employeesSelect = $('[data-select-employees]');

    if (employeesSelect.length > 0) {
      data.vacation.employee_id = employeesSelect.find(':selected').val();
    } else {
      data.vacation.employee_id = $('#vacation_master_id').val();
    }
    data.vacation.half_day = $('[data-half-day]').prop('checked');
    data.vacation.category = $('[data-type]:radio:checked').val();
    if ($('[data-start-date]').val().length > 0 && $('[data-end-date]').val().length > 0) {
      data.vacation.from = $('[data-start-date]').val();
      data.vacation.to = $('[data-end-date]').val();
    }
    data.master = $('#master').val();

    $.ajax({
      url: '/manager/vacations/vacation_days',
      type: 'GET',
      data: data
    }).done(function(response) {
        var errorText;

      toggleHalfDayCheckbox(response.working_days);
      var startDatepicker = $('[data-current-datepicker]');
      var endDatepicker = $('[data-launch-datepicker]');
      var startDate = new Date(startDatepicker.data('datetimepicker').getDate());
      var endDate = new Date(endDatepicker.data('datetimepicker').getDate());
      var nextYear = new Date().getFullYear() + 1;

      const currentYear = new Date().getFullYear();

      function checkDuplicatesDates() {
        if (response.overlaps === true) {
          $('[data-duplicate-days-error]').removeClass('d-none');
          isDuplicate = true;
        } else {
          isDuplicate = false;
          $('[data-duplicate-days-error]').addClass('d-none');
        }
      }

      if (vacationType === 'vacation') {
        $('.vacation-fields__item--total').show();
        $('.vacation-fields__item--unpaid').hide();
        $('#vacation-fields__container--unpaid-message').hide();

        // startDate = current year AND endDate = next(later)Year
        if ((startDate.getFullYear() === currentYear) && (endDate.getFullYear() > currentYear)) {
          errorText = `Vacation range exceeded! Please make separate request for vacations in ${endDate.getFullYear()}`;
          toggleWorkingDays(false);
          toggleWorkingDaysError(true, errorText);
          toggleNotPaidDaysBlock(false, response.working_days);
          toggleTotalDaysError(false, errorText);

        // startDate = next(later)Year OR endDate = next(later)Year
        } else if (startDate.getFullYear() > nextYear || endDate.getFullYear() > nextYear) {
          errorText = `Vacation range exceeded! You cannot make vacation requests exceeding ${nextYear}`;
          toggleWorkingDays(false);
          toggleWorkingDaysError(true, errorText);

        // future employee AND startDate = current year or less
        } else if (response['future_employee?'] && startDate.getFullYear() < nextYear) {
          errorText = `You have no vacation days in ${startDate.getFullYear()}`;
          toggleWorkingDays(false);
          toggleWorkingDaysError(true, errorText);
        } else {
          // startDate = next(later)Year
          if (startDate.getFullYear() > currentYear) {
            totalVacationDays = response.current_year_days + response.next_year_days + response.working_days;
          } else {
            // startDate = current year AND endDate = currentYear
            totalVacationDays = response.current_year_days + response.past_year_days + response.next_year_days + response.working_days;
          }

          // requested days more than master has
          if (response.working_days > totalVacationDays) {
            errorText = `Vacation days quota exceeded! Your selected dates range includes ${
              response.working_days} working days, but you have only ${
              totalVacationDays} vacation days available.`;

            // startDate = next(later)year
            if ((startDate.getFullYear() > currentYear)) {
              errorText = `Vacation days quota exceeded! Your selected dates range includes ${
                response.working_days} working days in ${nextYear} but you have only ${
                totalVacationDays} vacation days available for ${nextYear}`;
            }

            toggleYearsContainers(false);
            if (response.overlaps === true) {
              toggleTotalDaysError(false, errorText);
              toggleNotPaidDaysBlock(false, response.working_days);
            } else {
              toggleTotalDaysError(true, errorText);
              toggleNotPaidDaysBlock(true, response.working_days);
            }
          } else {
            toggleNotPaidDaysBlock(false, response.working_days);
            toggleTotalDaysError(false);
            toggleYearsContainers(true);
          }
        }
      } else if (vacationType === 'sick') {
        totalSickDays = response.current_year_days + response.working_days;
        $('.vacation-fields__item--total').show();
        $('.vacation-fields__item--unpaid').hide();
        $('#vacation-fields__container--unpaid-message').hide();
        if (response['future_employee?']) {
          errorText = 'You cannot request for sick leave yet';
          toggleWorkingDays(false);
          toggleWorkingDaysError(true, errorText);
        } else {
          const vacationFrom = document.querySelector('#vacation_from').value;
          const vacationTo = document.querySelector('#vacation_to').value;

          if (startDate.getFullYear() !== endDate.getFullYear()) {
            if (vacationFrom && vacationTo) {
              errorText = `Sick leave range exceeded! Please make separate request for vacations in ${endDate.getFullYear()}`;
            }

            toggleWorkingDays(false);
            toggleWorkingDaysError(true, errorText);
            toggleNotPaidDaysBlock(false, response.working_days);
            toggleTotalDaysError(false, errorText);
          } else if (response.working_days > totalSickDays) {
            errorText = `Sick leaves quota exceeded! Your selected dates range includes ${response.working_days} working days, but you have only ${totalSickDays} paid sick leave days available. Please consider taking ${Math.floor(totalSickDays)} days as sick leaves, and the rest — as unpaid leave, or contact hr@masterofcode.com for assistance.`;
            if (response.overlaps === true) {
              toggleNotPaidDaysBlock(false, response.working_days);
              toggleTotalDaysError(false, errorText);
            } else {
              toggleNotPaidDaysBlock(true, response.working_days);
              toggleTotalDaysError(true, errorText);
            }
          } else if (startDate.getFullYear() > currentYear) {
            errorText = `You cannot request sick leave in ${startDate.getFullYear()}. Please consider taking ${response.working_days} days as unpaid leave, or contact hr@masterofcode.com for assistance.`;
            if (response.overlaps) {
              toggleNotPaidDaysBlock(false, response.working_days);
              toggleTotalDaysError(false, errorText);
            } else {
              toggleNotPaidDaysBlock(true, response.working_days);
              toggleTotalDaysError(true, errorText);
            }
          } else {
            toggleNotPaidDaysBlock(false, response.working_days);
            toggleTotalDaysError(false);
          }
        }
      } else if (vacationType === 'days-off') {
        $('[data-days-error]').hide();
        toggleYearsContainers(false);
        toggleTotalDaysError(false);
        toggleNotPaidDaysBlock(false, response.working_days);
        totalVacationDays = response.current_year_days + response.past_year_days;
        if (totalVacationDays > 0) {
          $('#vacation-fields__container--unpaid-message').show();
        } else {
          $('#vacation-fields__container--unpaid-message').hide();
        }
      }

      $('.vacation-days-left #current').html(response.current_year_days);
      $('.vacation-days-left #past').html(response.past_year_days);
      if (response.past_year_days <= 0) {
        $('.vacation-past-year').hide();
      } else {
        $('.vacation-past-year').show();
      }
      totalSickDays = response.current_year_days;
      $('[data-days-text]').html('Total working days: ');
      $('[data-days-text-unpaid]').html('Unpaid leave used: ');
      $('[data-days-number]').html(response.working_days);
      checkDuplicatesDates();
      toggleSubmitButtonAccess();
    });
  }

  function onEmployeeChange() {
    $('#vacation_master_id').on('change', function(e) {
      load_vacation_days(vacationType);
    });
  }

  function onDateInputChange() {
    $('[data-date]').on('change', function(e) {
      $('[data-half-day]').prop('checked', false);
      setTimeout(function() {
        load_vacation_days(vacationType);
      }, 0);
    });
  }

  function requestOpenModal() {
    $('.open-request-form').on('click', function () {
      load_vacation_days(vacationType);
    });
  }

  function onDatePickerChange() {
    var noTimeChoosedDate;
    var datepicker = $('[data-datepicker]').datetimepicker({
      pickTime: false
    });

    datepicker.on('changeDate', function(ev) {
      var startDatepicker = $('[data-current-datepicker]');
      var endDatepicker = $('[data-launch-datepicker]');
      var startDateInp = $('[data-start-date]');
      var endDateInp = $('[data-end-date]');

      if (noTimeChoosedDate !== new Date(ev.date).setHours(0, 0, 0, 0)) {
        $('[data-half-day]').prop('checked', false);
        noTimeChoosedDate = new Date(ev.date).setHours(0, 0, 0, 0);
      }

      if (startDateInp.val().length > 0 && endDateInp.val().length > 0) {
        var startDate = new Date(startDatepicker.data('datetimepicker').getDate());
        var endDate = new Date(endDatepicker.data('datetimepicker').getDate());

        if (endDate < startDate) {
          toggleWorkingDays(false);
          toggleWorkingDaysError(true, 'Please adjust the start and end dates!');
        } else {
          toggleWorkingDaysError(false);
          toggleWorkingDays(true);
        }
      } else {
        toggleWorkingDaysError(false);
        toggleWorkingDays(false);
      }

      load_vacation_days(vacationType);
      hideDateTimePicker();
    });
  }

  function onVacationTypeChange() {
    $('[data-type]').on('change', function(e) {
      var vacationTypeValue = e.target.value;

      if (vacationTypeValue === 'days-off') {
        toggleYearsContainers(false);
      } else if (vacationTypeValue === 'sick') {
        toggleYearsContainers(false);
      }
      vacationType = vacationTypeValue;
      load_vacation_days(vacationType);
    });
  }

  function onHalfDayChecboxChange() {
    $('[data-half-day]').on('change', function(e) {
      load_vacation_days(vacationType);
    });
  }

  function onNotPaidDaysCheckboxChange() {
    $('[data-not-paid-days]').on('change', function() {
      toggleSubmitButtonAccess();
    });
  }

  function toggleHalfDayCheckbox(workingDays) {
    var halfDayChecbox = $('[data-half-day]');
    var halfDayChecboxChecked = halfDayChecbox.prop('checked');

    if (!halfDayChecboxChecked && workingDays > 1  || !halfDayChecboxChecked && !workingDays) {
      isCheckboxDisabled(true);
    } else {
      isCheckboxDisabled(false);
    }
  }

  function isCheckboxDisabled(isDisabled) {
    var halfDayChecboxText = $('[data-half-day-text]');
    var halfDayChecbox = $('[data-half-day]');

    halfDayChecbox.prop( 'disabled', isDisabled );
    halfDayChecboxText.toggleClass('vacation-label__text--grey', isDisabled);
  }

  function toggleYearsContainers(isVisible) {
    var pastYearContainer = $('[data-past-year]');
    var currentYearContainer = $('[data-current-year]');

    if (!isVisible) {
      pastYearContainer.fadeOut(0);
      currentYearContainer.fadeOut(0);
    } else {
      pastYearContainer.fadeIn(300);
      currentYearContainer.fadeIn(300);
    }
  }

  function toggleSubmitButtonAccess() {
    var vacationCategoryLength = $('[data-type]').val().length;
    var startDateLength = $('[data-start-date]').val().length;
    var endDateLength = $('[data-end-date]').val().length;
    var submitBtn = $('[data-vacation-submit-btn]');

    var isAllFieldsFilled = vacationCategoryLength > 0 && startDateLength > 0 && endDateLength > 0;
    var isNoErrors = !isWorkingDaysError && !isTotalDaysError && !isDuplicate;
    var isPaidDaysChecked = $('[data-not-paid-days]').length && $('[data-not-paid-days]').prop('checked');

    if ((isAllFieldsFilled && isNoErrors) || (isAllFieldsFilled && isTotalDaysError && isPaidDaysChecked)) {
      submitBtn.prop('disabled', false);
    } else {
      submitBtn.prop('disabled', true);
    }
  }

  function toggleWorkingDays(isVisible) {
    const textContainer = $('[data-days-text]');
    const dayNumberContainer = $('[data-days-number]');

    if (isVisible) {
      textContainer.fadeIn(300);
      dayNumberContainer.fadeIn(300);
    } else {
      textContainer.fadeOut(0);
      dayNumberContainer.fadeOut(0);
    }
  }

  function toggleTotalDaysError(isError, errorText) {
    if (errorText == null) {
      errorText = '';
    }
    var totalDaysErrorEl = $('[data-total-days-error]');

    totalDaysErrorEl.html(errorText);
    if (isError) {
      totalDaysErrorEl.fadeIn(300);
      isTotalDaysError = true;
    } else {
      totalDaysErrorEl.fadeOut(0);
      isTotalDaysError = false;
    }
  }

  function toggleWorkingDaysError(isError, errorText) {
    if (errorText == null) {
      errorText = '';
    }

    var workingDaysError = $('[data-days-error]');

    workingDaysError.html(errorText);
    isWorkingDaysError = isError;
  }

  function toggleNotPaidDaysBlock(isEnable, workingDays) {
    var notPaidBlock = $('[data-not-paid-block]');
    var errorMessage;
    var startDatepicker = $('[data-current-datepicker]');
    var startDate = new Date(startDatepicker.data('datetimepicker').getDate());

    switch (vacationType) {
      case 'vacation':
          if (startDate.getFullYear() > new Date().getFullYear()) {
              errorMessage = `I agree that this vacation will include ${workingDays - totalVacationDays} days that will be taken off next year's vacation days`;
          } else {
              errorMessage = `I agree that this vacation will include ${Math.round(workingDays - totalVacationDays)} days that won't be compensated or paid for`;
          }
        break;
      case 'sick':
        if (startDate.getFullYear() > new Date().getFullYear()) {
          errorMessage = `I agree that this sick leave will include ${workingDays} days that won't be compensated or paid for`;
        } else {
          errorMessage = `I agree that this sick leave will include ${Math.round(workingDays - totalSickDays)} days that won't be compensated or paid for`;
        }
        break;
    }
    $('[data-not-paid-days-text]').html(errorMessage);
    notPaidBlock.toggleClass('d-none', !isEnable);
  }

  function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1));
    var sURLVariables = sPageURL.split('&');
    var sParameterName = undefined;
    var i = undefined;

    i = 0;
    while (i < sURLVariables.length) {
      sParameterName = sURLVariables[i].split('=');
      if (sParameterName[0] === sParam) {
        if (sParameterName[1] === undefined) {
          return true;
        } else {
          return sParameterName[1];
        }
      }
      i++;
    }
  }

  function resetVacationsInfo() {
    totalVacationDays = 0;
    totalSickDays = 0;
    vacationType = 'vacation';
    isWorkingDaysError = false;
    isTotalDaysError = false;
  }

  function chooseVacation() {
    const timeOffRatioButtons = document.querySelectorAll('.vacation__item input[type="radio"]');
    const activeClass = 'vacation__item-active';

    timeOffRatioButtons.forEach(radioButton => {
      const closestButton = radioButton.closest('li');

      if (radioButton.checked) {
        closestButton.classList.add(activeClass);
      } else {
        closestButton.classList.remove(activeClass);
      }
    });
  }

  function addListenerToTimeOffButtons() {
    const timeOffRatioButtons = document.querySelectorAll('.vacation__item input[type="radio"]');

    timeOffRatioButtons.forEach(radioButton => {
      if (radioButton) {
        if (radioButton.value === 'vacation') {
          radioButton.checked = true;
        }

        radioButton.addEventListener('click', chooseVacation);
      }
    });
    chooseVacation();
  }

  function initExportLogic() {
    const exportBtn = document.querySelector('#btn_export_vacations');

    if (!exportBtn) {
      return;
    }

    exportBtn.addEventListener('click', () => {
      const fromDateEl = document.querySelector('#time-off-from-date');
      const toDateEl = document.querySelector('#time-off-to-date');

      if (!fromDateEl || !toDateEl) {
        return;
      }

      const isFromDateChosen = fromDateEl.value !== '';
      const isToDateChosen = toDateEl.value !== '';

      if (isFromDateChosen && isToDateChosen) {
        sendRequestToExportVacation();
      } else {
        window.openPopup('#mm-modal-export-popup');
      }
    });
  }

  function vacationExportCsv(exportToCsvUrl) {
    const urlParams = Object.fromEntries(new URLSearchParams(exportToCsvUrl));
    const fileName = `Vacations Report from ${urlParams.filter_start_date} to ${urlParams.filter_end_date}.csv`;

    window.axios.get(exportToCsvUrl)
      .then((response) => {
        window.downloadFile(response.data, fileName);
      });
  }

  function sendRequestToExportVacation() {
    const params = gather_vacations_filters();

    // TODO: remove after ticket: https://mocglobal.atlassian.net/browse/MM-636
    const headers = { 'Accept': ' application/json' };

    window.axios.get('/manager/vacations/ajax_export', { params, headers })
    .then((response) => {
      vacationExportCsv(response.data.export_to_csv_url);
    });
  }

  function hideDateTimePicker() {
    $('.bootstrap-datetimepicker-widget').hide();
  }

  // This function is already exists in separate file as library, but only on staging. So it should be removed in the future
  function addCsrfTokenToRequestHeaders(requestHeaders) {
    const tokenDomElement = document.querySelector('meta[name="csrf-token"]');

    if (tokenDomElement) {
      requestHeaders.append('X-CSRF-Token', tokenDomElement.content);
    }

    return requestHeaders;
  }

  function getNewVacationFormData(formDomElement) {
    const formData = new FormData(formDomElement);
    const endDate = new Date(formData.get('to').toString());

    // set additional param for be
    if (formData.get('category') === 'sick' && endDate.getFullYear() > new Date().getFullYear()) {
      formData.set('sick_leave_unpaid', 'true');
    } else {
      formData.set('sick_leave_unpaid', 'false');
    }

    return formData;
  }

  function handleClickForAddVacationBtn() {
    const formDomElement = document.querySelector('#new_vacation');
    const formData = getNewVacationFormData(formDomElement);
    const sendBtn = document.querySelector('#add-vacation-request-submit-btn');
    const sendBtnDisabledOldValue = sendBtn.disabled;

    sendBtn.disabled = true;

    fetch(formDomElement.action, {
      method: formDomElement.method,
      body: formData,
      headers: addCsrfTokenToRequestHeaders(new Headers())
    }).then((response) => {
      if (response && response.ok) {
        location.reload();
      } else if (response.status === 401 || response.status === 403) {
        location.replace(response.headers.get('Location'));
      } else {
        sendBtn.disabled = sendBtnDisabledOldValue;
      }
    }).catch(() => {
      sendBtn.disabled = sendBtnDisabledOldValue;
    });
  }

  function attachHandlersToAddVacationBtnClick() {
    const btn = document.querySelector('#add-vacation-request-submit-btn');

    if (btn) {
      btn.addEventListener('click', handleClickForAddVacationBtn);
    }
  }

  $(document).ready(vacations_ready);

  $(document).on('page:load', vacations_ready);
  // TODO: refactor this page
  // Ticket: https://mocglobal.atlassian.net/browse/MM-666
}).call(this);
