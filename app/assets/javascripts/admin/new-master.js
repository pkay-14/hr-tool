function aprAddMasterLocalScope() {
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

  function validateNewMasterForm() {
    const updateButton = $('.update-button');

    if ($('#user_company_division option:selected').val() === 'none' ||
      $('#user_position option:selected').val() === 'none' ||
      $('#user_community option:selected').val() === 'none' ||
      $('#user_english_level option:selected').val() === 'none' ||
      $('#user_people_partner_id option:selected').val() === '' ||
      $('#user_first_name').val() === '' || $('#user_last_name').val() === '' ||
      $('#user_hired_at').val() === '' || $('#user_moc_email').val() === '' ||
      $('#user_tel_number').val() === '') {
      updateButton.attr('type', 'button');
      updateButton.attr('disabled', true);
    } else {
      updateButton.attr('type', 'submit');
      updateButton.attr('disabled', false);
    }
  }

  function onClickAddLogicToChangingEnglishLevel(event) {
    const englishLevelErrorText = document.querySelector('#english-level-error-text');
    const englishLevelSelect = document.querySelector('#user_english_level');

    if (event.target.value === 'none') {
      showOrHideErrorMessage({
        message: englishLevelErrorText,
        field: englishLevelSelect,
        toShow: true
      });
    } else {
      showOrHideErrorMessage({
        message: englishLevelErrorText,
        field: englishLevelSelect,
        toShow: false
      });
    }
  }

  function addListenerToEnglishLevelSelect() {
    const englishLevelErrorText = document.querySelector('#english-level-error-text');
    const englishLevelSelect = document.querySelector('#user_english_level');
    const englishLevelSelectedOption = $('#user_english_level option:selected').val();

    if (englishLevelSelect) {
      englishLevelSelect.addEventListener('change', () => {
        validateNewMasterForm();
        onClickAddLogicToChangingEnglishLevel(event);
      });
      if (englishLevelSelectedOption === 'none') {
        showOrHideErrorMessage({
          message: englishLevelErrorText,
          field: englishLevelSelect,
          toShow: true
        });
      }
    }
  }

  function addListenerToAgreementDateField() {
    const agreementErrorText = document.querySelector('#date-agreement-error-text');
    const agreementField = document.querySelector('.profile-form__input--agreement-date');
    const agreementInput = document.querySelector('#user_hired_at');

    $('.profile-form__input--agreement-date').datetimepicker({
      weekStart: 1
    }).on('changeDate', () => {
      validateNewMasterForm();
      showOrHideErrorMessage({
        message: agreementErrorText,
        field: agreementField,
        toShow: false
      });
      if (agreementInput.value.length > 0) {
        showOrHideErrorMessage({
          message: agreementErrorText,
          field: agreementField,
          toShow: false
        });
      }
    });

    if (agreementInput.value.length === 0) {
      showOrHideErrorMessage({
        message: agreementErrorText,
        field: agreementField,
        toShow: true
      });
    }
  }

  function addListenerToNameField(nameField, errorText) {
    if (!nameField) return;

    nameField.addEventListener('keyup', () => {
      validateNewMasterForm();
      showOrHideErrorMessage({
        message: errorText,
        field: nameField,
        toShow: false
      });
      if (nameField.value !== '') {
        showOrHideErrorMessage({
          message: errorText,
          field: nameField,
          toShow: false
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
      showOrHideErrorMessage({
        message: errorText,
        field: nameField,
        toShow: true
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
        validateNewMasterForm();
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
    const corporateEmailInput = document.querySelector('#user_moc_email');
    const firstNameErrorText = document.querySelector('#first-name-error-text');
    const lastNameErrorText = document.querySelector('#last-name-error-text');
    const corporateEmailErrorText = document.querySelector('#corporate-email-error-text');

    addListenerToNameField(firstNameInput, firstNameErrorText);
    addListenerToNameField(lastNameInput, lastNameErrorText);
    addListenerToNameField(corporateEmailInput, corporateEmailErrorText);
  }

  function addListenerToCareerHistoryField(nameField, errorText) {
    if (!nameField) return;

    nameField.addEventListener('change', () => {
      validateNewMasterForm();
      showOrHideErrorMessage({
        message: errorText,
        field: nameField,
        toShow: false
      });
      if (nameField.value !== 'none') {
        showOrHideErrorMessage({
          message: errorText,
          field: nameField,
          toShow: false
        });
      }
    });

    if (nameField.value === 'none') {
      showOrHideErrorMessage({
        message: errorText,
        field: nameField,
        toShow: true
      });
    }
  }

  function addListenerToCareerHistoryFields() {
    const companyDivisionInput = document.querySelector('#user_company_division');
    const companyDivisionErrorText = document.querySelector('#company-division-error-text');
    const communityInput = document.querySelector('#user_community');
    const communityErrorText = document.querySelector('#community-error-text');
    const positionInput = document.querySelector('#user_position');
    const positionErrorText = document.querySelector('#position-error-text');

    addListenerToCareerHistoryField(companyDivisionInput, companyDivisionErrorText);
    addListenerToCareerHistoryField(communityInput, communityErrorText);
    addListenerToCareerHistoryField(positionInput, positionErrorText);
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
      validateNewMasterForm();
    });
    if (inputPhoneField.value === '') {
      showOrHideErrorMessage({
        message: phoneNumberErrorText,
        field: inputPhoneField,
        toShow: true
      });
    }
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
      validateNewMasterForm();
    });
    if (inputEmailField.value === '') {
      showOrHideErrorMessage({
        message: corporateEmailErrorText,
        field: inputEmailField,
        toShow: true
      });
    }
  }

  function addListenerToUpdateButton() {
    const updateButton = $('.update-button');

    updateButton.attr('disabled', false);
    updateButton.on('click', () => {
      validateNewMasterForm();
      addListenerToPeoplePartnerSelect();
      addListenerToCareerHistoryFields();
      addListenerToEnglishLevelSelect();
      addListenerToAgreementDateField();
      addCorporateEmailValidation();
      addPhoneValidation();
      addListenerToNameFields();
    });
  }

  function init() {
    validateNewMasterForm();
    addListenerToUpdateButton();
  }

  $(document).ready(init);
}

if (location.pathname.includes('/admin/employees/new') || location.pathname.match(/admin\/employees$/)) {
  aprAddMasterLocalScope.call(this);
}
