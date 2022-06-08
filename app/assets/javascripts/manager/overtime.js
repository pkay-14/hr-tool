function initOvertimesPage() {
  function closeModal() {
    $('.hr-header').css('z-index', '7');
    $('.mm-background-overlay').css('display', 'none');
    $('body').css('overflow', 'auto');
  }

  function openModal() {
    $('.hr-header').css('z-index', '5');
    $('.mm-background-overlay').css('display', 'flex');
    $('body').css('overflow', 'hidden');
  }

  function openDropdownTimeLogged() {
    $('.icon-more').on('click', function () {
      $(this).closest('td').children('.modal-time-logged').removeClass('hide');
      $(this).closest('td').children('.modal-time-logged').addClass('tr-time-logged-flex');
      $(this).closest('td').css('z-index', 'unset');
      openModal();
    });

    $('.close-time-logged').on('click', function () {
      $(this).closest('td').children('.modal-time-logged').addClass('hide');
      $(this).closest('td').children('.modal-time-logged').removeClass('tr-time-logged-flex');
      $(this).closest('td').css('z-index', '2');
      $('.icon-comment-time-logged').closest('.time-logged-block').next('.comment-time-logged').addClass('hide');
      closeModal();
    });

    $('.mm-background-overlay').click(function (event) {
      if (!$(event.target).closest('.modal-time-logged').length) {
        const modalElement = $('body').find('.modal-time-logged');

        modalElement.addClass('hide');
        modalElement.removeClass('tr-time-logged-flex');

        if ($(this).hasClass('desktop-overlay-overtimes')) {
          closeModal();
          $(this).removeClass('desktop-overlay-overtimes');
          $('.icon-comment-time-logged').closest('.time-logged-block').next('.comment-time-logged').addClass('hide');
        }
      }
    });

    $('.icon-comment-time-logged').on('click', function () {
      $(this).closest('.time-logged-block').next('.comment-time-logged').toggleClass('hide');
    });
  }

  function comment() {
    const editButtons = document.querySelectorAll('[data-button-edit-comment-overtime]');
    const cancelButtons = document.querySelectorAll('.btn-cancel-edit');

    editButtons.forEach(function (btn) {
      btn.addEventListener('click', function () {
        const btnDataId = btn.getAttribute('data-button-edit-comment-overtime');
        const commentContainerEl = document.querySelector(`[data-edit-comment-container-for-overtime="${btnDataId}"]`);

        commentContainerEl.classList.add('show-edit-comment');
        btn.closest('.comment-container').nextElementSibling.classList.remove('hide');
        btn.closest('td').style.zIndex = 'unset';
        openModal();
      });
    });

    cancelButtons.forEach(function (btn) {
      btn.addEventListener('click', function () {
        btn.closest('.mm-modal-custom').classList.remove('show-edit-comment');
        btn.closest('.mm-modal-custom').classList.add('hide');
        btn.closest('td').style.zIndex = '2';
        closeModal();
      });
    });
  }

  function undo() {
    const undoButtons = document.querySelectorAll('[data-btn-for-undo-overtime]');
    const closeUndoButtons = document.querySelectorAll('.close-undo');

    undoButtons.forEach(function (btn) {
      btn.addEventListener('click', function (event) {
        const overtimeId = event.target.getAttribute('data-btn-for-undo-overtime');
        const undoPopupEl = document.querySelector(`[data-modal-for-undo-overtime="${overtimeId}"]`);

        undoPopupEl.style.display = 'block';
        btn.closest('td').style.zIndex = 'unset';
        openModal();
      });
    });

    closeUndoButtons.forEach(function (btn) {
      btn.addEventListener('click', function () {
        btn.closest('#undo-modal').style.display = 'none';
        btn.closest('td').style.zIndex = '2';
        closeModal();
      });
    });
  }

  /**
   * Rerender overtimes masters list on page
   * @param {string} htmlAsString Html for insert in #overtimes_list
   */
  function overwriteOvertimesListHtml(htmlAsString) {
    document.querySelector('#overtimes_list').innerHTML = htmlAsString;
    initOvertimesListPart();
  }

  /**
   * Send request for filtered masters list and rerender masters list page part
   * @param {Object.<string, string>} [additionalParams = {}] An object with additional request params
   */
  function sendFilterRequest(additionalParams = {}) {
    // sometimes we have url params '?master=true'
    const currentUrlSearchParams = new URLSearchParams(window.location.search);
    const requestParams = {
        ...Object.fromEntries(currentUrlSearchParams),
        ...getOvertimeListFilters(),
        ...additionalParams
      };

    window.axios.get('/manager/overtimes/search', { params: requestParams })
      .then(response => overwriteOvertimesListHtml(response.data));
  }

  function overtimes_ajax_filters() {
    const inputFilterThrottle = window.throttle(sendFilterRequest);

    $('#overtimes #search-form input').on('input', function (e) {
      e.preventDefault();
      inputFilterThrottle();
    });

    if (location.pathname.includes('manager/overtimes')) {
      function getDateRequest(date) {
        date.datetimepicker({
          pickTime: false
        }).on('changeDate', () => {
          sendFilterRequest();
        });
      }

      getDateRequest($('[data-datepicker-overtime-to]'));
      getDateRequest($('[data-datepicker-overtime-from]'));
    }

    $('#view_report_link').on('click', function (e) {
      e.preventDefault();
      const filters = getOvertimeListFilters();

      $.ajax({
        url: '/manager/overtimes/report',
        type: 'GET',
        data: filters
      });
    });


    $('#overtime-status-filter li').on('click', function (e) {
      e.preventDefault();
      let toggleLink;
      const self = $(this);

      self.parent().find('.hide').removeClass('hide');
      self.addClass('hide');

      if (self.is('[data-status]')) {
        toggleLink = $('[data-current-status]');
        toggleLink.attr('data-current-status', self.attr('data-status'));
      }
      toggleLink.text(self.text());

      sendFilterRequest();
    });

    function checkHeightModalTimeLogged() {
      const modalLogged = document.querySelectorAll('.modal-logged-body');
      const iconMore = document.querySelectorAll('.icon-more');
      const desktopOverlay = document.querySelector('.mm-background-overlay');

      iconMore.forEach(function (i) {
        i.addEventListener('click', function () {
          desktopOverlay.classList.add('desktop-overlay-overtimes');
          modalLogged.forEach(function (j) {
            if (j.offsetHeight > 300) {
              j.style.height = '300px';
              j.style.maxWidth = '460px';
              j.style.overflowY = 'scroll';
            }
          });
        });
      });
    }

    checkHeightModalTimeLogged();
  }

  function addButtonExportToSheetClickHandler() {
    $('#btn_export_to_sheets').on('click', function (e) {
      e.preventDefault();

      const btn = document.querySelector('#btn_export_to_sheets');
      const queryString = window.location.search;
      const btnOldInnerText = btn.innerText;
      const params = getOvertimeListFilters();

      btn.disabled = true;
      btn.innerText = 'Exporting...';

      $.ajax({
        url: `/manager/overtimes/export${queryString}`,
        type: 'post',
        data: { ...{ 'export': true, format: 'json' }, ...params }
      }).done(function (response) {
        open_link(response.url);
      }).always(() => {
        btn.disabled = false;
        btn.innerText = btnOldInnerText;
      });
    });
  }

  function open_link(url) {
    if (url !== '' || url != null) {
      window.open(url);
    }
  }

  function getOvertimeListFilters() {
    return {
      status: document.querySelector('[data-current-status]').getAttribute('data-current-status'),
      from: document.querySelector('#overtime-from-date').value,
      to: document.querySelector('#overtime-to-date').value,
      query: document.querySelector('#query').value
    };
  }

  function toggle_button_attribute() {
    $('#hr_overtime_submit_comment_button').attr('disabled', 'disabled');
    check_list_hr();
  }

  function check_list_hr() {
    const project_list = $('.hr_overtime_approve_project_list');
    const comment_box = $('.hr_overtime__textarea');

    comment_box.on('keyup', function () {
      if (comment_box.val().length < 2 || (project_list.val() === 'Select project')) {
        $('#hr_overtime_submit_comment_button').attr('disabled', 'disabled');
      } else {
        $('#hr_overtime_submit_comment_button').removeAttr('disabled');
      }
    });

    project_list.on('change', function () {
      if (comment_box.val().length < 2 || (project_list.val() === 'Select project')) {
        $('#hr_overtime_submit_comment_button').attr('disabled', 'disabled');
      } else {
        $('#hr_overtime_submit_comment_button').removeAttr('disabled');
      }
    });
  }

  function edit_comment() {
    const checkBtn = document.querySelectorAll('.mm-button-save');
    const currentUser = document.querySelector('#current_user');
    const desktopOverlay = document.querySelector('.mm-background-overlay');

    checkBtn.forEach(function (i) {
      i.addEventListener('click', function () {
        i.closest('.mm-modal-custom').classList.remove('show-edit-comment');
        i.closest('.mm-modal-custom').classList.add('hide');
        i.closest('.mm-modal-custom').previousElementSibling.children[2].textContent = currentUser.value + i.closest('form').children[3].value;
        desktopOverlay.style.display = 'none';
      });
    });
  }

  edit_comment();

  function validationTextarea() {
    $('.edit-comment').keyup(function () {
      if ($(this).val().length <= 1) {
        $('.mm-button-save').attr('disabled', 'disabled');
        $(this).closest('form').children('.error-comment').css('display', 'flex');
        $(this).addClass('error-border');
        $(this).css('border', 'none !important');
      } else {
        $('.mm-button-save').removeAttr('disabled');
        $(this).closest('form').children('.error-comment').css('display', 'none');
        $(this).removeClass('error-border');
        $(this).css('border', '1px solid #e5e5e5 !important');
      }
    });

    $('.hr_overtime__textarea-confirmation').keyup(function () {
      if ($(this).val().length <= 1) {
        $(this).addClass('error-border');
        $(this).css('border', 'none !important');
        $('.error-comment').css('display', 'block');
      } else {
        $('.error-comment').css('display', 'none');
        $(this).removeClass('error-border');
        $(this).css('border', '1px solid #e5e5e5 !important');
      }
    });
  }

  function onPaginationPageClick(event) {
    event.preventDefault();
    // Backend globally adding additional click event for all pagination in project (kaminari gem).
    // We have to block it. Other Way we will have 2 same requests on click.
    event.stopPropagation();

    const paginationUrl = new URL(event.target.href);
    const page = paginationUrl.searchParams.get('page') || '1';

    sendFilterRequest({ page });
  }

  function addListenersForPagination() {
    const paginationButtons = document.querySelectorAll('div.pagination ul li a');

    paginationButtons.forEach(buttonEl => {
      buttonEl.addEventListener('click', onPaginationPageClick);
    });
  }

  function initOvertimesListPart() {
    openDropdownTimeLogged();
    edit_comment();
    validationTextarea();
    comment();
    undo();
    addListenersForPagination();
  }

  function onDOMContentLoadedHandler() {
    toggle_button_attribute();
    overtimes_ajax_filters();
    addButtonExportToSheetClickHandler();
    initOvertimesListPart();
  }

  document.addEventListener('DOMContentLoaded', onDOMContentLoadedHandler);
}

if (location.pathname.match(/^\/manager\/overtimes/)) {
  initOvertimesPage();
}
