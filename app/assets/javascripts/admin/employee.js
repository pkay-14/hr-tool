(function() {
  var timer = null;

  function employee_filters() {
    $('#employee li[data-tech], #employee li[data-user-status], #employee li[data-role-status]' +
        ', #employee li[data-legal-status], #employee li[data-office]' +
        ', #employee li[data-company-division], #employee li[data-community]' +
        ', #employee li[data-position], #employee li[data-people-partner]').on('click', () => {
      sortingSandbox.resetSortinOrder();
      employee_filters_request();
    });

    $('#employee .search-form').on('change keyup paste propertychange', () => {
      clearTimeout(timer);
      timer = setTimeout(employee_filters_request, 1500);
    });

    $('#employee .items-on-page').on('change', employee_filters_request);
  }

  function employee_filters_request() {
    const params = employee_filters_params();

    $.ajax({
      url: '/admin/employees/search',
      type: 'GET',
      data: params
    }).done(highlightOption);
  }

  function employee_filters_params() {
    return {
      tech: $('[data-current-tech]').attr('data-current-tech'),
      status: $('[data-current-status]').attr('data-current-status'),
      legal_status: $('[data-current-legal-status]').attr('data-current-legal-status'),
      role_status: $('[data-current-role-status]').attr('data-current-role-status'),
      office: $('[data-current-office]').attr('data-current-office'),
      company_division: $('[data-current-company-division]').attr('data-current-company-division'),
      community: $('[data-current-community]').attr('data-current-community'),
      position: $('[data-current-position]').attr('data-current-position'),
      people_partner: $('[data-current-people-partner]').attr('data-current-people-partner'),
      search_query: $('#employee .search-form input').val(),
      per_page: $('#employee .items-on-page').val()
    };
  }

  function employeeSort() {
    $('[data-employee-sort-control]').on('click', function() {
      var reqRout = '/admin/employees/search';
      var payload = {
        tech: $('[data-current-tech]').attr('data-current-tech'),
        status: $('[data-current-status]').attr('data-current-status'),
        legal_status: $('[data-current-legal-status]').attr('data-current-legal-status'),
        role_status: $('[data-current-role-status]').attr('data-current-role-status'),
        office: $('[data-current-office]').attr('data-current-office'),
        company_division: $('[data-current-company-division]').attr('data-current-company-division'),
        community: $('[data-current-community]').attr('data-current-community'),
        position: $('[data-current-position]').attr('data-current-position'),
        people_partner: $('[data-current-people-partner]').attr('data-current-people-partner'),
        search_query: $('#employee .search-form input').val(),
        per_page: $('#employee .items-on-page').val(),
        order_by: $(this).data('employee-sort-control')
      };
      var sortBy = $(this).data('employee-sort-control');
      var sortingIcon = `[data-employee-sort-icon=${$(this).data('employee-sort-control')}]`;

      sortingSandbox.sort(reqRout, payload, sortBy, sortingIcon);
    });
  }

  function onClickDeletePhoto() {
    function hidingPopup() {
      $('#mm-modal').css('display', 'none');
      $('.mm-background-overlay').css('display', 'none');
      $('body').css('overflow', 'auto');
    }

    function deletePhotoRequest(e) {
      e.preventDefault();
      const userId = $('.profile-form-list').attr('data-user-id');

      hidingPopup();

      $.ajax({
        url: `/admin/employees/${userId}/remove_photo`,
        type: 'POST',
        data: {}
      });
    }

    $('#delete-photo').on('click', deletePhotoRequest);
  }

  function exportMastersToFile() {
    window.axios.get('/admin/employees/export', { params: employee_filters_params() })
      .then((response) => {
        const headerLine = response.headers['content-disposition'];
        const startFileNameIndex = headerLine.indexOf('"') + 1;
        const endFileNameIndex = headerLine.lastIndexOf('"');
        const filename = headerLine.substring(startFileNameIndex, endFileNameIndex);

        window.downloadFile(response.data, filename);
      });
  }

  function addListenerToExportToCsvButton() {
    document.querySelector('#export-to-csv--button')
      ?.addEventListener('click', exportMastersToFile);
  }

  function showMastersCabinetTimeOffPopup() {
    window.openPopup('#masters-cabinet-time-off-details--popup');
  }

  function addLogicToTimeOffInfoButton() {
    const timeOffInfoButton = document.querySelector('#masters-cabinet-time-off-info-button');

    timeOffInfoButton?.addEventListener('click', showMastersCabinetTimeOffPopup);
  }

  function employee_ready() {
    const masterForm = document.querySelector('#master-form');

    $('[data-user-img=1]').popover({
      html: true,
      trigger: 'click hover',
      delay: {
        'show': 500, 'hide': 500
      },
      placement: 'left',
      content: function() {
        var current_user_img = $(this).find('img').attr('src');

        $('.img-popover img').attr('src', current_user_img);
        return $($(this).data('popwrapper')).html();
      }
    });

    if ($(window).width() < 991) {
      $('[data-user-img=1]').popover('destroy');
    }

    $('.date').datetimepicker({
      weekStart: 1
    }).on('changeDate', hideDateTimePicker);

    validationFields();
    croppie();
    hide_filter_options();
    showHiddenText();
    employeeSort();
    $('.add_skill_link').on('cocoon:after-insert', addListenerToLevelButtons);
    validateAdditionalFields();
    addListenerToLevelButtons();
    addListenerToExportToCsvButton();
    initiateSelect2();
    window.onKeydownPreventDefaultEnter(masterForm);
    addLogicToTimeOffInfoButton();

    $('#employee .dropdown-menu li').on('click', function(e) {
      var toggleLink;

      e.preventDefault();
      var self = $(this);

      self.parent().find('.hide').removeClass('hide');
      self.addClass('hide');
      if (self.is('[data-tech]')) {
        toggleLink = $('[data-current-tech]');
        toggleLink.attr('data-current-tech', self.attr('data-tech'));
      } else if (self.is('[data-user-status]')) {
        toggleLink = $('[data-current-status]');
        toggleLink.attr('data-current-status', self.attr('data-user-status'));
      } else if (self.is('[data-legal-status]')) {
        toggleLink = $('[data-current-legal-status]');
        toggleLink.attr('data-current-legal-status', self.attr('data-legal-status'));
      } else if (self.is('[data-role-status]')) {
        toggleLink = $('[data-current-role-status]');
        toggleLink.attr('data-current-role-status', self.attr('data-role-status'));
      } else if (self.is('[data-office]')) {
        toggleLink = $('[data-current-office]');
        toggleLink.attr('data-current-office', self.attr('data-office'));
      } else if (self.is('[data-company-division]')) {
        toggleLink = $('[data-current-company-division]');
        toggleLink.attr('data-current-company-division', self.attr('data-company-division'));
      } else if (self.is('[data-community]')) {
        toggleLink = $('[data-current-community]');
        toggleLink.attr('data-current-community', self.attr('data-community'));
      } else if (self.is('[data-position]')) {
        toggleLink = $('[data-current-position]');
        toggleLink.attr('data-current-position', self.attr('data-position'));
      } else if (self.is('[data-people-partner]')) {
        toggleLink = $('[data-current-people-partner]');
        toggleLink.attr('data-current-people-partner', self.attr('data-people-partner'));
      }
      return toggleLink.text(self.text());
    });

    $('[data-hint]').popover({
      trigger: 'hover',
      placement: 'bottom'
    });

    $('#master-profile .open-feedbacks, #candidate-profile .open-feedbacks').on('click', function(e) {
      $(this).parent().toggleClass('opened');
      return false;
    });

    employee_filters();
    onClickDeletePhoto();

    $(document).on('click', '[data-meeting-id] .trash-icon', function() {
      var meeting_id = $(this).closest('.career-comments-row').attr('data-meeting-id');

      $('#delete-comment').attr('data-meeting-id', meeting_id);
      $('#confirm-modal').show();
    });

    $('#delete-comment').on('click', function(e) {
      e.preventDefault();
      var meeting_id = $('#delete-comment').attr('data-meeting-id');
      var meeting = $(`.career-comments-row[data-meeting-id=${meeting_id}]`);

      $.ajax({
        url: `/admin/employees/clear_career_comment/${meeting_id}`,
        type: 'DELETE',
        data: {}
      }).done(function() {
        $('#confirm-modal-meeting').hide();
        $('.modal-backdrop').fadeOut('slow');
        meeting.remove();
      });
    });

    $('input#contract_signed').click(function() {
      var signed;

      if ($(this).prop('checked')) {
        signed = '1';
      } else {
        signed = '0';
      }
      $(this).closest('form').submit();
    });

    onCountryChange();
  }

  function hide_filter_options() {
    $('#employees-technology .dropdown-menu li').first().addClass('hide');
    $('#employees-legal-status .dropdown-menu li').first().addClass('hide');
    $('#employees-role-status .dropdown-menu li').first().addClass('hide');
    $('#employees-office .dropdown-menu li').first().addClass('hide');
    $('#employees-status .dropdown-menu li').first().addClass('hide');
    $('#employees-company-division .dropdown-menu li').first().addClass('hide');
    $('#employees-community .dropdown-menu li').first().addClass('hide');
    $('#employees-position .dropdown-menu li').first().addClass('hide');
    $('#employees-people-partner .dropdown-menu li').first().addClass('hide');
  }

  function showHiddenText() {
    $('.cut-td').on('click', function() {
      $(this).toggleClass('shown');
    });
  }

  function set_social_days_per_year() {
    var data = { user: {} };

    data.user.country_id = $('#user_country_id').find(':selected').val();

    $.ajax({
      url: '/admin/employees/social_days_per_year',
      type: 'GET',
      data: data
    }).done(function(response) {
      $('#user_vacation_days_per_year').val(response.vacation_days_per_year);
      $('#user_sick_days_per_year').val(response.sick_days_per_year);
    });
  }

  function onCountryChange() {
    $('#user_country_id').on('change', function(e) {
      set_social_days_per_year();
    });
  }

  function croppie() {
    const newImage = document.querySelector('.result-img');
    const img = new Image();
    const demo = $('#demo');

    $('input[type=file]').change(function () {
      const self = $(this);
      const fileInput = self[0];
      const file = fileInput.files && fileInput.files[0];

      newImage.src = '';
      $('.img-val').val('');
      demo.croppie('destroy');
      showCropperPopup();
      img.src = window.URL.createObjectURL( file );
      validateImage();

      const basic = demo.croppie({
        viewport: {
          width: 200,
          height: 200,
          type: 'circle'
        },
        boundary: {
          width: 500,
          height: 400
        }
      });

      basic.croppie('bind', {
        url: img.src
      });

      function resetInputFile() {
        $('.filename').text('Choose file');
        $('.img-val').val('');
        self.val('');
      }

      function setResultAfterCropping() {
        basic.croppie('result', {
          type: 'base64',
          size: 'viewport'
        }).then((res) => {
          $('.modal__inner').css('display', 'none');
          $('.modal-croppie-result').css('display', 'flex');
          $('.modal-croppie').addClass('modal-croppie-resize');
          newImage.src = res;
          $('.img-val').val(newImage.src);
        });
      }

      $('.btn-close-modal-croppie').on('click', () => {
        hideCropperPopup($('.modal-croppie'));
        resetInputFile();
      });
      $('.btn-result').on('click', setResultAfterCropping);
      $('.btn-ok').on('click', () => {
        hideCropperPopup($('.modal-croppie'));
      });
      $(' #delete-photo').on('click', resetInputFile);
    });

    function hideCropperPopup(popup) {
      $('body').css('overflow', 'visible');
      $('.mm-background-overlay').css('display', 'none');
      popup.css('display', 'none');
    }

    function showCropperPopup() {
      $('body').css('overflow', 'hidden');
      $('.modal-croppie').removeClass('modal-croppie-resize').css('display', 'flex');
      $('.mm-background-overlay').css('display', 'flex');
      $('.modal__inner').css('display', 'flex');
      $('.modal-croppie-result').css('display', 'none');
    }

    function showWrongFormatPopup() {
      $('body').css('overflow', 'hidden');
      $('#mm-modal--wrong-format').css('display', 'block');
      $('.mm-background-overlay').css('display', 'flex');
    }

    function validateImage() {
      const formData = new FormData();
      const photo = document.getElementById('photo');
      const file = photo.files[0];
      const fileType = file.type.split('/').pop().toLowerCase();

      formData.append('Filedata', file);

      if (fileType !== 'jpeg' && fileType !== 'jpg' && fileType !== 'png') {
        hideCropperPopup($('.modal-croppie'));
        showWrongFormatPopup();
        demo.croppie('destroy');
        photo.value = '';
        return false;
      }
      return true;
    }

    $('.close-modal--wrong-format').on('click', () => {
      hideCropperPopup($('#mm-modal--wrong-format'));
    });
  }

  function errorMessage() {
    const skillNames = document.querySelectorAll('.skill-name .field_with_errors label');
    const errorField = document.querySelectorAll('.skill-name .field_with_errors select');
    const errorText = document.createElement('p');

    skillNames.forEach(i => i.closest('div').style.border = 'none');

    errorField.forEach(i => {
      errorText.classList.add('error-skill');
      errorText.textContent = 'Duplicated Technology';
      i.closest('div').after(errorText);
    });
  }

  function checkStateOfRadioButton() {
    const lvlRatioButtons = document.querySelectorAll('.edit-skills__item input[type="radio"]');
    const activeClass = 'vacation__item-active';

    lvlRatioButtons.forEach(radioButton => {
      const closestButton = radioButton.closest('button');

      if (radioButton.checked) {
        closestButton.classList.add(activeClass);
      } else {
        closestButton.classList.remove(activeClass);
      }
    });
  }

  function addListenerToLevelButtons() {
    const lvlRatioButtons = document.querySelectorAll('.edit-skills__item input[type="radio"]');

    lvlRatioButtons.forEach(radioButton => {
      if (radioButton) {
        radioButton.addEventListener('click', checkStateOfRadioButton);
      }
    });
    checkStateOfRadioButton();
  }


  function hideDateTimePicker() {
    $('.bootstrap-datetimepicker-widget').hide();
  }

  $(document).ready(function() {
    return $('.country-profile-form__select').on('change', function() {
      return $.ajax({
        url: '/admin/employees/offices',
        type: 'GET',
        dataType: 'script',
        data: {
          country_id: $('.country-profile-form__select option:selected').val()
        }
      });
    });
  });

  function attachDivisionCommunityChangeHandler() {
    $('#user_company_division').on('change', onDivisionChange);
    $('#user_community').on('change', onCommunityChange);
  }

  function onDivisionChange() {
    $.ajax({
      url: '/admin/employees/communities',
      type: 'GET',
      dataType: 'text',
      data: {
        company_division: $('#user_company_division option:selected').val()
      }
    }).done(resp => {
      const communitySelect = $('#user_community');

      communitySelect.empty().append(resp);

      // if only 'none' option freeze the select
      const isNoneOnly = communitySelect[0].length <= 1;

      communitySelect.prop( 'disabled', isNoneOnly );


      $('#user_position option:contains("none")').prop( 'selected', true );
      $('#user_position').prop( 'disabled', true );
    });
  }

  function onCommunityChange() {
    $.ajax({
      url: '/admin/employees/positions',
      type: 'GET',
      dataType: 'text',
      data: {
        community: $('#user_community option:selected').val()
      }
    }).done(resp => {
      const positionSelect = $('#user_position');

      positionSelect.empty().append(resp);
      // only 'none' option
      if (positionSelect[0].length <= 1) {
        positionSelect.prop( 'disabled', true );
      } else {
        positionSelect.prop( 'disabled', false );
      }
    });
  }

  function validateAdditionalFields() {
    $('.add_additional_vacation_link').on('cocoon:after-insert', () => {
      $('.additional-vacation-days').each(function () {
        window.addNumberValidationForInputField($(this)[0], 1);
      });
    });
  }

  function onKeyUpValidateText(i) {
    i.on('keyup', function () {
      i.val(i.val().replace(/[^a-zA-Z-а-яА-Я-іІ-їЇ-єЄ']/, ''));
    });
  }

  function onKeyUpValidateTelephoneNumbers() {
    const telephoneNumber = $('#user_tel_number');

    telephoneNumber.on('keyup', function () {
      telephoneNumber.val(telephoneNumber.val().replace(/[A-Za-zA-Яа-яЁё]/, ''));
    });
  }

  function onKeyUpValidateDatePicker(datepicker) {
    datepicker.on('keyup', function () {
      datepicker.val(datepicker.val().replace(/[^0-9.]/, ''));
    });
  }

  function onKeyUpValidateDatePickers() {
    onKeyUpValidateDatePicker($('#user_birthday'));
    onKeyUpValidateDatePicker($('#time-off-from-date'));
    onKeyUpValidateDatePicker($('#time-off-to-date'));
    onKeyUpValidateDatePicker($('#overtime-from-date'));
    onKeyUpValidateDatePicker($('#overtime-to-date'));
    onKeyUpValidateDatePicker($('#overtime-approve-from-date'));
    onKeyUpValidateDatePicker($('#overtime-approve-to-date'));
  }

  function validationFields() {
    $('#passport_info_phone_number').on('keyup', function () {
      $(this).val($(this).val().replace (/[^0-9+ ]+/, ''));
    });
    $('#passport_info_edrpou').on('keyup', function () {
      $(this).val($(this).val().replace (/[^0-9]+/, ''));
    });
    window.addNumberValidationForInputField(document.querySelector('#user_vacation_days_per_year'), 1);
    window.addNumberValidationForInputField(document.querySelector('#user_sick_days_per_year'), 1);
    window.addNumberValidationForInputField(document.querySelector('#user_sick_days'), 1);
    window.addNumberValidationForInputField(document.querySelector('#user_days_off'), 1);
    onKeyUpValidateText($('#passport_info_last_name'));
    onKeyUpValidateText($('#passport_info_first_name'));
    onKeyUpValidateText($('#passport_info_middle_name'));
    onKeyUpValidateText($('#passport_info_genitive_case'));
    onKeyUpValidateText($('#user_first_name'));
    onKeyUpValidateText($('#user_last_name'));
    onKeyUpValidateTelephoneNumbers();
    onKeyUpValidateDatePickers();
  }

  function initiateSelect2() {
    const select2El = $('.select2-js');

    if (select2El.length) {
      select2El.select2({
        dropdownParent: $('#citiesSelectParent'),
        width: '100%'
      });
    }
  }

  $(document).on('page:load', attachDivisionCommunityChangeHandler).ready(attachDivisionCommunityChangeHandler);
  $(document).on('page:load', errorMessage).ready(errorMessage);
  $(document).on('page:load', employee_ready).ready(employee_ready);
}).call(this);
