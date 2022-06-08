function editMasterLocalScope() {
  function showOrHideErrorMessage({ message, field, toShow }) {
    const submitButton = document.querySelector('#update-master__button');
    const errorBorder = 'error-border';

    if (toShow === true) {
      message.style.display = 'flex';
      field.classList.add(errorBorder);
      submitButton.setAttribute('disabled', 'disabled');
    } else {
      message.style.display = 'none';
      field.classList.remove(errorBorder);
    }
  }

  function showPopup(popup) {
    popup.css('display', 'block');
    $('.mm-background-overlay').css('display', 'block');
  }

  function hidePopup(popup) {
    popup.css('display', 'none');
    $('.mm-background-overlay').css('display', 'none');
  }

  function getValueFromPositionField() {
    const positionSelect = document.querySelector('#user_position');

    if (!positionSelect) return;

    const positionValue = positionSelect.value;

    localStorage.setItem('position', positionValue);
  }

  function getValueFromWorkingStatus() {
    const workingStatusSelect = document.querySelector('#user_working_status');

    if (!workingStatusSelect) return;

    const workingStatusSelectValue = workingStatusSelect.value;

    localStorage.setItem('status', workingStatusSelectValue);
  }

  function addLogicToValueOnCareerHistorySelects() {
    const updateButton = $('.update-button');

    if ($('#user_company_division option:selected').val() === 'none' ||
      $('#user_position option:selected').val() === 'none' ||
      $('#user_community option:selected').val() === 'none' || $('#user_first_name').val() === '' ||
      $('#user_last_name').val() === '' || $('#user_english_level option:selected').val() === 'none' ||
      $('#user_moc_email').val() === '' || $('#user_people_partner_id option:selected').val() === '' ||
      $('#user_tel_number').val() === '') {
      updateButton.attr('disabled', true);
    } else {
      updateButton.attr('disabled', false);
    }
  }

  function addListenerToNameField(nameField, errorText) {
    const submitButton = document.querySelector('#update-master__button');

    if (!nameField) return;

    nameField.addEventListener('keyup', () => {
      addLogicToValueOnCareerHistorySelects();
      submitButton.removeAttribute('disabled');
      showOrHideErrorMessage({
        message: errorText,
        field: nameField,
        toShow: false
      });
      if (nameField.value !== '') {
        submitButton.addEventListener('click', () => {
          addLogicToValueOnCareerHistorySelects();
            showOrHideErrorMessage({
              message: errorText,
              field: nameField,
              toShow: false
            });
        });
      } else {
        showOrHideErrorMessage({
          message: errorText,
          field: nameField,
          toShow: true
        });
      }
    });

    if (nameField.value === '') {
      submitButton.addEventListener('click', () => {
        showOrHideErrorMessage({
          message: errorText,
          field: nameField,
          toShow: true
        });
      });
    }
  }

  function onClickAddLogicToChangingEnglishLevel(event) {
    const submitButton = document.querySelector('#update-master__button');
    const englishLevelErrorText = document.querySelector('.english-level-error__text');
    const englishLevelSelect = document.querySelector('#user_english_level');

    if (event.target.value === 'none') {
      showOrHideErrorMessage({
        message: englishLevelErrorText,
        field: englishLevelSelect,
        toShow: true
      });
    } else {
      submitButton.addEventListener('click', () => {
        addLogicToValueOnCareerHistorySelects();
        showOrHideErrorMessage({
          message: englishLevelErrorText,
          field: englishLevelSelect,
          toShow: false
        });
      });
      submitButton.removeAttribute('disabled');
      showOrHideErrorMessage({
        message: englishLevelErrorText,
        field: englishLevelSelect,
        toShow: false
      });
    }
  }

  function addListenerToEnglishLevelSelect() {
    const submitButton = document.querySelector('#update-master__button');
    const englishLevelErrorText = document.querySelector('.english-level-error__text');
    const englishLevelSelect = document.querySelector('#user_english_level');
    const englishLevelSelectedOption = $('#user_english_level option:selected').val();

    if (!englishLevelSelect) return;

    englishLevelSelect.addEventListener('change', () => {
      onClickAddLogicToChangingEnglishLevel(event);
      addLogicToValueOnCareerHistorySelects();
    });
    if (englishLevelSelectedOption === 'none') {
      submitButton.addEventListener('click', () => {
        showOrHideErrorMessage({
          message: englishLevelErrorText,
          field: englishLevelSelect,
          toShow: true
        });
      });
    }
  }

  function onClickAddLogicToPeoplePartner() {
    const peoplePartnerErrorText = document.querySelector('#people-partner-error-text');
    const peoplePartnerSelect = document.querySelector('#user_people_partner_id');

    if (peoplePartnerSelect.value === '') {
      showOrHideErrorMessage({
        message: peoplePartnerErrorText,
        field: peoplePartnerSelect,
        toShow: true
      });
    } else {
      showOrHideErrorMessage({
        message: peoplePartnerErrorText,
        field: peoplePartnerSelect,
        toShow: false
      });
    }
  }

  function addListenerToPeoplePartnerSelect() {
    const peoplePartnerErrorText = document.querySelector('#people-partner-error-text');
    const peoplePartnerSelect = document.querySelector('#user_people_partner_id');
    const peoplePartnerSelectedOption = $('#user_people_partner_id option:selected').val();

    if (peoplePartnerSelect) {
      peoplePartnerSelect.addEventListener('change', () => {
        addLogicToValueOnCareerHistorySelects();
        onClickAddLogicToPeoplePartner();
      });
      if (peoplePartnerSelectedOption === '') {
        showOrHideErrorMessage({
          message:  peoplePartnerErrorText,
          field: peoplePartnerSelect,
          toShow: true
        });
      }
    }
  }

  function addListenerToNameFields() {
    const firstNameInput = document.querySelector('#user_first_name');
    const lastNameInput = document.querySelector('#user_last_name');
    const firstNameErrorText = document.querySelector('.first-name-error__text');
    const lastNameErrorText = document.querySelector('.last-name-error__text');

    addListenerToNameField(firstNameInput, firstNameErrorText);
    addListenerToNameField(lastNameInput, lastNameErrorText);
  }

  function addCorporateEmailValidation() {
    const EMAIL_REGEXP = /^(?=.{1,254}$)(?!.*[.@]{2})(?!.*@masterofcode.com$)/i;
    const inputEmailField = document.querySelector('#user_moc_email');
    const corporateEmailErrorText = document.querySelector('#corporate-email-error-text');
    const corporateEmailErrorTextDomain = document.querySelector('.corporate-email-error__text--domain');

    $('.edit-user-form').on('submit', (e) => {
      if (EMAIL_REGEXP.test(inputEmailField.value)) {
        e.preventDefault();
        showOrHideErrorMessage({
          message: corporateEmailErrorTextDomain,
          field: inputEmailField,
          toShow: true
        });
      }

      inputEmailField.addEventListener('keyup', () => {
        showOrHideErrorMessage({
          message: corporateEmailErrorTextDomain,
          field: inputEmailField,
          toShow: false
        });
        showOrHideErrorMessage({
          message: corporateEmailErrorText,
          field: inputEmailField,
          toShow: false
        });
      });
    });

    if (!inputEmailField) return;

    inputEmailField.addEventListener('keyup', () => {
      if (inputEmailField.value === '') {
        showOrHideErrorMessage({
          message: corporateEmailErrorText,
          field: inputEmailField,
          toShow: true
        });
      } else {
        showOrHideErrorMessage({
          message: corporateEmailErrorText,
          field: inputEmailField,
          toShow: false
        });
      }
      addLogicToValueOnCareerHistorySelects();
    });
    if (inputEmailField.value === '') {
      showOrHideErrorMessage({
        message: corporateEmailErrorText,
        field: inputEmailField,
        toShow: true
      });
    }
  }

  function addPhoneValidation() {
    const inputPhoneField = document.querySelector('#user_tel_number');
    const phoneNumberErrorText = document.querySelector('#phone-number-error-text');

    if (!inputPhoneField) return;

    inputPhoneField.addEventListener('keyup', () => {
      if (inputPhoneField.value === '') {
        showOrHideErrorMessage({
          message: phoneNumberErrorText,
          field: inputPhoneField,
          toShow: true
        });
      } else {
        showOrHideErrorMessage({
          message: phoneNumberErrorText,
          field: inputPhoneField,
          toShow: false
        });
      }
      addLogicToValueOnCareerHistorySelects();
      addLogicToCareerHistoryFields();
    });
    if (inputPhoneField.value === '') {
      showOrHideErrorMessage({
        message: phoneNumberErrorText,
        field: inputPhoneField,
        toShow: true
      });
    }
  }

  function validateDismissedDate() {
    const userLeftAt = document.querySelector('#user_left_at');
    const leftAtDateContainer = document.querySelector('#left-at-date--container');
    const dateChangeErrorText = document.querySelector('.date-change-error__text');

    if (userLeftAt.value.length !== 10) {
      showOrHideErrorMessage({
        message: dateChangeErrorText,
        field: leftAtDateContainer,
        toShow: true
      });
    } else {
      showOrHideErrorMessage({
        message: dateChangeErrorText,
        field: leftAtDateContainer,
        toShow: false
      });
    }
  }

  function validateWorkingStatus(message, status) {
    const workingStatusSelect = document.querySelector('#user_working_status');

    if (workingStatusSelect.value !== status) {
      showOrHideErrorMessage({
        message: message,
        field: workingStatusSelect,
        toShow: true
      });
    } else {
      showOrHideErrorMessage({
        message: message,
        field: workingStatusSelect,
        toShow: false
      });
    }
  }

  function validateChangesDates() {
    const userChangesDate = document.querySelector('#user_changes_date');
    const changeDateContainer = document.querySelector('#user-changes-date--container');
    const userChangesDateErrorText = document.querySelector('#user-changes-date-error__text-id');

    if (userChangesDate.value.length !== 10) {
      showOrHideErrorMessage({
        message: userChangesDateErrorText,
        field: changeDateContainer,
        toShow: true
      });
    } else {
      showOrHideErrorMessage({
        message: userChangesDateErrorText,
        field: changeDateContainer,
        toShow: false
      });
    }
  }

  function setDisabledAttrForUpdateButton() {
    const updateButton = $('.update-button');

    if ($('.left-at-date-validation__text').hasClass('left-at-date-validation__text--active')) {
      updateButton.attr('disabled', true);
    } else {
      updateButton.attr('disabled', false);
    }

    if ($('.change-date-validation__text--end').hasClass('change-date-validation__text--end-active')) {
      updateButton.attr('disabled', true);
    } else {
      updateButton.attr('disabled', false);
    }

    if ($('.change-date-validation__text--start').hasClass('change-date-validation__text--start-active')) {
      updateButton.attr('disabled', true);
    } else {
      updateButton.attr('disabled', false);
    }
  }

  function validateDismissedSelect() {
    const dismissedSelect = document.querySelector('#user_left_reason');
    const dismissedErrorText = document.querySelector('#dismissed-error-text');

    if (dismissedSelect.value === 'none') {
      showOrHideErrorMessage({
        message: dismissedErrorText,
        field: dismissedSelect,
        toShow: true
      });
    } else {
      showOrHideErrorMessage({
        message: dismissedErrorText,
        field: dismissedSelect,
        toShow: false
      });
    }
  }

  function addLogicToCreateExMaster() {
    const workingStatusSelect = document.querySelector('#user_working_status');
    const userLeftAt = document.querySelector('#user_left_at');
    const submitButton = document.querySelector('#update-master__button');
    const userLeftReason = document.querySelector('#user_left_reason');
    const leftAtDateValidationText = document.querySelector('.left-at-date-validation__text');

    if (workingStatusSelect.value === 'Ex Master' && userLeftAt.value.length === 10 &&
      userLeftReason.value !== 'none' &&
      !leftAtDateValidationText.classList.contains('left-at-date-validation__text--active')) {
      submitButton.setAttribute('type', 'submit');
      submitButton.removeAttribute('disabled');
    } else {
      submitButton.setAttribute('type', 'button');
    }
  }

  function resetLeftAtAndLeftReasonFields() {
    const userLeftAt = document.querySelector('#user_left_at');
    const userLeftReason = document.querySelector('#user_left_reason');

    userLeftAt.value = '';
    userLeftReason.value = 'none';
  }

  function validateFunctionForReturningMaster() {
    const userChangesDate = $('#user_changes_date');
    const updateButton = $('.update-button');
    const workingStatusSelectedValue = $('#user_working_status option:selected').val();
    const userPositionSelectedValue = $('#user_position option:selected').val();

    $('#user_company_division, #user_position, #user_community').attr('disabled', false);

    if (workingStatusSelectedValue === 'Master' && userChangesDate.val() !== '' &&
      userPositionSelectedValue === localStorage.getItem('position') && userPositionSelectedValue !== 'none' &&
      !$('.change-date-validation__text--end').hasClass('change-date-validation__text--end-active')) {
      updateButton.attr('type', 'submit');
    } else {
      updateButton.attr('type', 'button');
    }
  }

  function validationEditMasterPage() {
    const workingStatusSelect = document.querySelector('#user_working_status');
    const statusChangeErrorText = document.querySelector('.status-change-error__text');
    const statusChangeErrorTextEx = document.querySelector('.status-change-error__text--ex');
    const userChangesDate = document.querySelector('#user_changes_date');
    const userPositionSelectedValue = $('#user_position option:selected').val();
    const updateButton = $('.update-button');

    if (!workingStatusSelect) return;

    workingStatusSelect.addEventListener('change', () => {
      showOrHideErrorMessage({
        message: statusChangeErrorText,
        field: workingStatusSelect,
        toShow: false
      });

      showOrHideErrorMessage({
        message: statusChangeErrorTextEx,
        field: workingStatusSelect,
        toShow: false
      });

      if (workingStatusSelect.value === localStorage.getItem('status')) {
        if (workingStatusSelect.value === 'Master') {
          setDisabledAttrForUpdateButton();
          updateButton.attr('type', 'submit');
          $('#user_company_division, #user_community, #user_position, #changes-date-icon').attr('disabled', false);
          $('#user_left_reason, #left-at__button, #user_left_comment').attr('disabled', true);
          resetLeftAtAndLeftReasonFields();
        }

        if (workingStatusSelect.value === 'Ex Master') {
          setDisabledAttrForUpdateButton();
          $('#user_company_division, #user_community, #user_position').attr('disabled', true);
          $('#user_left_reason, #left-at__button, #update-master__button').attr('disabled', true);
        }
      } else {
        if (workingStatusSelect.value === 'Master') {
          validateFunctionForReturningMaster();
          resetLeftAtAndLeftReasonFields();
          updateButton.on('click', validateChangesDates);
          $('#user_left_reason, #left-at__button').attr('disabled', true);
          $('#user_company_division, #user_community, #user_position, #changes-date-icon, #update-master__button').attr('disabled', false);
          if (userChangesDate.value !== '') {
            addLogicToCareerHistoryFields();
          }
        }

        if (workingStatusSelect.value === 'Ex Master') {
          addLogicToCreateExMaster();
          $('#user_company_division, #user_community, #user_position, #changes-date-icon').attr('disabled', true);
          $('#user_left_reason, #left-at__button, #user_left_comment').attr('disabled', false);
          userChangesDate.value = '';
          $('.change-date-validation__text--previous').hide().removeClass('change-date-validation__text--previous-active');

          if (userPositionSelectedValue !== 'none' || localStorage.getItem('position') !== userPositionSelectedValue) {
            updateButton.attr('disabled', true);
          } else {
            updateButton.attr('disabled', false);
          }
        }
      }
    });

    addListenerForUserLeftReason();
    addListenerLeftAtDate();
    addListenerToChangeDate();
  }

  function addListenerForUserLeftReason() {
    const workingStatusSelect = document.querySelector('#user_working_status');
    const dismissedErrorText = document.querySelector('#dismissed-error-text');
    const userLeftReason = document.querySelector('#user_left_reason');
    const updateButton = $('.update-button');

    if (!userLeftReason) return;

    userLeftReason.addEventListener('change', () => {
      addLogicToValueOnCareerHistorySelects();
      setDisabledAttrForUpdateButton();
      showOrHideErrorMessage({
        message: dismissedErrorText,
        field: userLeftReason,
        toShow: false
      });

      addLogicToCreateExMaster();

      if (userLeftReason.value === 'none') {
        $('#user_company_division, #user_community, #user_position, #changes-date-icon').attr('disabled', false);
      } else {
        $('#user_company_division, #user_community, #user_position, #changes-date-icon').attr('disabled', true);
      }

      if (workingStatusSelect.value === localStorage.getItem('status')) {
        if (userLeftReason.value === 'none') {
          updateButton.attr('type', 'submit');
        } else {
          updateButton.attr('type', 'button');
        }
      }
    });
  }

  function addListenerLeftAtDate() {
    const dateChangeErrorText = document.querySelector('.date-change-error__text');
    const leftAtDateContainer = document.querySelector('#left-at-date--container');

    $('#left-at-date--container').datetimepicker({
      weekStart: 1
    }).on('changeDate', () => {
      onChangeLeftAtDate();
      addLogicToCreateExMaster();
      addLogicToValueOnCareerHistorySelects();
      showOrHideErrorMessage({
        message: dateChangeErrorText,
        field: leftAtDateContainer,
        toShow: false
      });
      $('#user_company_division, #user_community, #user_position, #changes-date-icon').attr('disabled', true);
    });
  }

  function addListenerToChangeDate() {
    const workingStatusSelect = document.querySelector('#user_working_status');
    const userLeftReason = document.querySelector('#user_left_reason');
    const userLeftAt = document.querySelector('#user_left_at');
    const changeDateContainer = document.querySelector('#user-changes-date--container');
    const userChangesDateErrorText = document.querySelector('#user-changes-date-error__text-id');
    const workingStatusSelectedValue = $('#user_working_status option:selected').val();
    const changesDate = $('.changes-date');
    const updateButton = $('.update-button');

    changesDate.datetimepicker({
      weekStart: 1,
      pickTime: false,
      format: 'dd.MM.yyyy'
    }).on('changeDate', () => {
      addLogicToValueOnCareerHistorySelects();
      showOrHideErrorMessage({
        message: userChangesDateErrorText,
        field: changeDateContainer,
        toShow: false
      });

      if (workingStatusSelect.value === 'Ex Master') {
        addLogicToCreateExMaster();
      }

      if (workingStatusSelect.value === localStorage.getItem('status')) {
        const userPositionSelectedValue = $('#user_position option:selected').val();

        if (workingStatusSelect.value === 'Master') {
          if (workingStatusSelectedValue === 'Ex Master') {
            userLeftReason.value = 'none';
            userLeftAt.value = '';
          }

          if (userPositionSelectedValue === localStorage.getItem('position')) {
            changePreviousDateForMaster();
          }

          if (userPositionSelectedValue !== localStorage.getItem('position')) {
            changeDateForMaster();
          }

          $('#user_left_reason, #left-at__button').attr('disabled', true);
          addLogicToCareerHistoryFields();
        }

        if (workingStatusSelect.value === 'Ex Master') {
          changeDateForExMaster();
        }

        if (userPositionSelectedValue !== localStorage.getItem('position') && userPositionSelectedValue !== 'none') {
          updateButton.attr('type', 'button');
        }
      } else {
        const userPositionSelectedValue = $('#user_position option:selected').val();

        if (workingStatusSelect.value === 'Master') {
          if (userPositionSelectedValue !== localStorage.getItem('position') && userPositionSelectedValue !== 'none') {
            changeDateForExMaster();
            addLogicToCareerHistoryFields();
          }
          changeDateForExMaster();
          validateFunctionForReturningMaster();
          resetLeftAtAndLeftReasonFields();
        }
      }
    });

    changesDate.datetimepicker('setDate', null);
  }

  function changeDateForExMaster() {
    const currentDateInput = $('[data-current-date]');
    const oldDateInputEnd = $('.profile-form__input--hidden-end').val();
    const currentDate = new Date(currentDateInput.data('datetimepicker').getDate()).setHours(0, 0, 0, 0);
    const oldDateEnd = new Date(oldDateInputEnd).setHours(0, 0, 0, 0);
    const changeDateValidationText = $('.change-date-validation__text--end');
    const updateButton = $('.update-button');

    if (currentDate <= oldDateEnd) {
      changeDateValidationText.css('display', 'block');
      changeDateValidationText.addClass('change-date-validation__text--end-active');
      updateButton.attr('disabled', true);
    } else {
      changeDateValidationText.css('display', 'none');
      changeDateValidationText.removeClass('change-date-validation__text--end-active');
      updateButton.attr('disabled', false);
    }
  }

  function changeDateForMaster() {
    const currentDateInput = $('[data-current-date]');
    const oldDateInputStart = $('.profile-form__input--hidden-start').val();
    const currentDate = new Date(currentDateInput.data('datetimepicker').getDate()).setHours(0, 0, 0, 0);
    const oldDateStart = new Date(oldDateInputStart).setHours(0, 0, 0, 0);
    const changeDateValidationText = $('.change-date-validation__text--start');
    const updateButton = $('.update-button');

    if ((currentDate <= oldDateStart) && $('#user_changes_date').val() !== '') {
      changeDateValidationText.css('display', 'block');
      changeDateValidationText.addClass('change-date-validation__text--start-active');
      updateButton.attr('disabled', true);
    } else {
      changeDateValidationText.css('display', 'none');
      changeDateValidationText.removeClass('change-date-validation__text--start-active');
      updateButton.attr('disabled', false);
    }
  }

  function changePreviousDateForMaster() {
    const currentDateInput = $('[data-current-date]');
    const previousDateInputStart = $('.profile-form__input--hidden-previous-start').val();
    const currentDate = new Date(currentDateInput.data('datetimepicker').getDate()).setHours(0, 0, 0, 0);
    const previousDateStart = new Date(previousDateInputStart).setHours(0, 0, 0, 0);
    const changeDateValidationText = $('.change-date-validation__text--previous');
    const updateButton = $('.update-button');

    if ((currentDate <= previousDateStart) && $('#user_changes_date').val() !== '') {
      changeDateValidationText.css('display', 'block');
      changeDateValidationText.addClass('change-date-validation__text--previous-active');
      updateButton.attr('disabled', true);
    } else {
      changeDateValidationText.css('display', 'none');
      changeDateValidationText.removeClass('change-date-validation__text--previous-active');
      updateButton.attr('disabled', false);
    }
  }

  function onChangeLeftAtDate() {
    const leftAtDateField = $('[data-current-left-at-date]');
    const oldDateInput = $('.profile-form__input--hidden-start').val();
    const leftAtDate = new Date(leftAtDateField.data('datetimepicker').getDate());
    const oldDate = new Date(oldDateInput);
    const updateButton = $('.update-button');

    if (leftAtDate > oldDate) {
      $('.left-at-date-validation__text').css('display', 'none').removeClass('left-at-date-validation__text--active');
      $('#user_left_reason').removeClass('space-b-35');
      updateButton.attr('disabled', false);
    } else {
      $('.left-at-date-validation__text').css('display', 'block').addClass('left-at-date-validation__text--active');
      $('#user_left_reason').addClass('space-b-35');
      updateButton.attr('disabled', true);
    }
  }

  function addListenerToSubmitButton() {
    const submitButton = document.querySelector('#update-master__button');
    const userLeftAt = document.querySelector('#user_left_at');
    const workingStatusSelect = document.querySelector('#user_working_status');
    const userLeftReason = document.querySelector('#user_left_reason');
    const userChangesDate = document.querySelector('#user_changes_date');
    const statusChangeErrorText = document.querySelector('.status-change-error__text');
    const statusChangeErrorTextEx = document.querySelector('.status-change-error__text--ex');

    if (!submitButton) return;

    submitButton.addEventListener('click', () => {
      addLogicToValueOnCareerHistorySelects();
      addCorporateEmailValidation();
      if (userLeftAt.value.length === 10) {
        validateWorkingStatus(statusChangeErrorText, 'Ex Master');
        validateDismissedSelect();
      }

      if (workingStatusSelect.value === 'Ex Master' && userChangesDate.value.length === 0) {
        validateDismissedDate();
        validateDismissedSelect();
      }

      if (userLeftReason.value !== 'none') {
        validateWorkingStatus(statusChangeErrorText, 'Ex Master');
        validateDismissedDate();
      }

      if (workingStatusSelect.value === 'Ex Master' && userChangesDate.value.length === 10) {
        validateWorkingStatus(statusChangeErrorTextEx, 'Master');
      }
    });
  }

  function addLogicToCareerHistoryFields() {
    const updateButton = $('.update-button');
    const updateButtonPopup = $('.update-button--popup');
    const cancelButton =  $('.mm-modal-cancel-btn');
    const userPositionSelectedValue = $('#user_position option:selected').val();

    $('#user_company_division, #user_position, #user_community, #user_working_status').attr('disabled', false);
    if (userPositionSelectedValue !== 'none' && localStorage.getItem('position') !== userPositionSelectedValue) {
      updateButton.attr('type', 'button').on('click', () => {
        addLogicToValueOnCareerHistorySelects();
        showPopup($('#mm-modal--career-notifications'));
        updateButtonPopup.attr('disabled', false);
      });

      cancelButton.on('click', () => {
        hidePopup($('#mm-modal--career-notifications'));
      });
    } else {
      updateButton.attr('type', 'submit').on('click', () => {
        hidePopup($('#mm-modal--career-notifications'));
      });
    }
  }

  function addListenerToCareerHistoryFields() {
    const workingStatusSelectedValue = $('#user_working_status option:selected').val();
    const workingStatusSelect = document.querySelector('#user_working_status');
    const changeDateValidationTextStart = $('.change-date-validation__text--start');
    const changeDateValidationTextPrevious = $('.change-date-validation__text--previous');
    const userChangesDate = document.querySelector('#user_changes_date');
    const updateButton = $('.update-button');
    const companyDivisionInput = document.querySelector('#user_company_division');
    const companyDivisionErrorText = document.querySelector('#company-division-error-text');
    const communityInput = document.querySelector('#user_community');
    const communityErrorText = document.querySelector('#community-error-text');
    const positionInput = document.querySelector('#user_position');
    const positionErrorText = document.querySelector('#position-error-text');

    $('#user_company_division, #user_position, #user_community').on('change', () => {
      const userPositionSelectedValue = $('#user_position option:selected').val();

      if (workingStatusSelectedValue === 'Master') {
        $('#user_working_status, #user_left_reason, #left-at__button').attr('disabled', true);
      }

      if (workingStatusSelect.value === localStorage.getItem('status')) {
        if (workingStatusSelect.value === 'Master') {
          addLogicToCareerHistoryFields();
          if (userPositionSelectedValue === localStorage.getItem('position')) {
            changePreviousDateForMaster();
            changeDateValidationTextStart.css('display', 'none');
            changeDateValidationTextStart.removeClass('change-date-validation__text--start-active');
          } else {
            changeDateForMaster();
            changeDateValidationTextPrevious.css('display', 'none');
            changeDateValidationTextPrevious.removeClass('change-date-validation__text--previous-active');
          }

          if (userPositionSelectedValue === 'none') {
            changeDateValidationTextStart.css('display', 'none');
            changeDateValidationTextStart.removeClass('change-date-validation__text--start-active');
            changeDateValidationTextPrevious.css('display', 'none');
            changeDateValidationTextPrevious.removeClass('change-date-validation__text--previous-active');
          }
        }

        if (workingStatusSelect.value === 'Ex Master') {
          if (userChangesDate.value === '') {
            updateButton.attr('type', 'button');
          }
        }
      } else {
        if (workingStatusSelect.value === 'Master' && userChangesDate.value !== '') {
          updateButton.attr('type', 'button');
          updateButton.attr('disabled', false);
          addLogicToCareerHistoryFields();
        }
      }
      addListenerToCareerHistoryField(companyDivisionInput, companyDivisionErrorText);
      addListenerToCareerHistoryField(communityInput, communityErrorText);
      addListenerToCareerHistoryField(positionInput, positionErrorText);
    });
  }

  function checkCurrentWorkingStatus() {
    const workingStatusSelect = document.querySelector('#user_working_status');

    if (!workingStatusSelect) return;

    if (workingStatusSelect.value === localStorage.getItem('status')) {
      if (workingStatusSelect.value === 'Ex Master') {
        $('#user_left_reason, #left-at__button, #user_left_comment').attr('disabled', true);
        $('#user_company_division, #user_position, #user_community').attr('disabled', true);
      } else {
        $('#user_left_reason, #left-at__button, #user_left_comment').attr('disabled', true);
      }
    }
  }

  function addListenerToCareerHistoryField(nameField, errorText) {
    showOrHideErrorMessage({
      message: errorText,
      field: nameField,
      toShow: false
    });
    if (nameField.value === 'none') {
      showOrHideErrorMessage({
        message: errorText,
        field: nameField,
        toShow: true
      });
    }
  }

  function init() {
    getValueFromPositionField();
    getValueFromWorkingStatus();
    addLogicToValueOnCareerHistorySelects();
    addListenerToNameFields();
    addListenerToEnglishLevelSelect();
    addListenerToPeoplePartnerSelect();
    addCorporateEmailValidation();
    addPhoneValidation();
    addListenerToCareerHistoryFields();
    validationEditMasterPage();
    addListenerToSubmitButton();
    checkCurrentWorkingStatus();
  }

  $(document).ready(init);
}

if (location.pathname.match(/admin\/employees\/.*edit/) || location.pathname.match(/admin\/employees\/.{24}$/)) {
    editMasterLocalScope.call(this);
}
