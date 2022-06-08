function overtimeApprove() {
  function toggle_button_attribute() {
    $('#overtime_submit_comment_button').attr('disabled', 'disabled');
    check_list();
  }

  function check_list() {
    const project_list = $('.overtime_approve_project_list');
    const textarea_value = $('.overtime__textarea');

    textarea_value.on('keyup', function() {
      if (textarea_value.val().length < 2 || (project_list.val() === 'Select project')) {
        $('#overtime_submit_comment_button').attr('disabled', 'disabled');
      } else {
        $('#overtime_submit_comment_button').removeAttr('disabled');
      }
    });

    project_list.on('change', function() {
      if (textarea_value.val().length < 2 || (project_list.val() === 'Select project' )) {
        $('#overtime_submit_comment_button').attr('disabled', 'disabled');
      } else {
        $('#overtime_submit_comment_button').removeAttr('disabled');
      }
    });
  }

  function addFilterEventHandlers() {
    const inputFilterThrottle = window.throttle(requestFilteredMastersList);

    document.querySelector('#overtime-approve-master-filter-input')
      ?.addEventListener('input', inputFilterThrottle);
    $('[data-datepicker-overtime-approve-from]').on('changeDate', requestFilteredMastersList);
    $('[data-datepicker-overtime-approve-to]').on('changeDate', requestFilteredMastersList);

    $('#overtime-approve-status-filter li').on('click', function(e) {
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

      requestFilteredMastersList();
    });
  }

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

  function comment() {
    const editBtn = document.querySelectorAll('#edit-comment__btn');
    const cancelBtn = document.querySelectorAll('.btn-cancel-edit');

    editBtn.forEach( i => {
      i.addEventListener('click', () => {
        i.closest('.comment-container').nextElementSibling.children[0].children[1].children[0].classList.add('show-edit-comment');
        i.closest('.comment-container').nextElementSibling.classList.remove('hide');
        i.closest('td').style.zIndex = 'unset';
        openModal();
      });
    });

    cancelBtn.forEach(i => {
      i.addEventListener('click',  () => {
        i.closest('.mm-modal-custom').classList.remove('show-edit-comment');
        i.closest('.mm-modal-custom').classList.add('hide');
        i.closest('td').style.zIndex = '2';
        closeModal();
      });
    });
  }

  function undo() {
    const undoBtnHr = document.querySelectorAll('.undo-btn-hr');
    const closeUndoBtnHr = document.querySelectorAll('.close-undo-hr');

    undoBtnHr.forEach(i => {
      i.addEventListener('click', (event) => {
        const approveId = event.target.getAttribute('data-btn-for-undo-approve');
        const undoPopupEl = document.querySelector(`[data-modal-for-undo-approve="${approveId}"]`);

        undoPopupEl.style.display = 'block';
        openModal();
      });
    });

    closeUndoBtnHr.forEach(i => {
      i.addEventListener('click', () => {
        i.closest('[data-modal-for-undo-approve]').style.display = 'none';
        closeModal();
      });
    });
  }

  function openDropdownTimeLogged() {
    $('[data-show-overtime-details--button]').on('click', function () {
      $(this).closest('[data-time-logged--container]').children('.modal-time-logged').removeClass('hide');
      openModal();
    });

    $('.close-time-logged').on('click', function () {
      $(this).closest('[data-time-logged--container]').children('.modal-time-logged').addClass('hide');
      closeModal();
    });

    $('.mm-background-overlay').click(function(event) {
      if (!$(event.target).closest('.modal-time-logged').length) {
        $('body').find('.modal-time-logged').addClass('hide').removeClass('tr-time-logged-flex');
        if ($(this).hasClass('desktop-overlay-overtimes')) {
          closeModal();
          $(this).removeClass('desktop-overlay-overtimes');
          $('.icon-comment-time-logged').closest('.time-logged-block').next('.comment-time-logged').addClass('hide');
        }
      }
    });
  }

  function checkHeightModalTimeLogged() {
    const modalLogged = document.querySelectorAll('.modal-logged-body');
    const showPopupButtonEls = document.querySelectorAll('[data-show-overtime-details--button]');
    const desktopOverlay = document.querySelector('.mm-background-overlay');

    showPopupButtonEls.forEach(showPopupButtonEl => {
      showPopupButtonEl.addEventListener('click', () => {
        desktopOverlay.classList.add('desktop-overlay-overtimes');
        modalLogged.forEach(modalBody => {
          if (modalBody.offsetHeight > 300) {
            modalBody.style.height = '300px';
            modalBody.style.maxWidth = '460px';
            modalBody.style.overflowY = 'scroll';
          }
        });
      });
    });
  }

  function getOvertimeApproveFilterParams() {
    return {
      status: $('[data-current-status]').attr('data-current-status'),
      from: $('#overtime-approve-from-date').val().toString(),
      to: $('#overtime-approve-to-date').val().toString(),
      query: $('#overtimes #approve-search-form input').val()
    };
  }

  function onPaginationPageClick(event) {
    event.preventDefault();
    // Backend globally adding additional click event for all pagination in project (kaminari gem).
    // We have to block it. Other Way we will have 2 same requests on click.
    event.stopPropagation();

    const paginationUrl = new URL(event.target.href);
    const page = paginationUrl.searchParams.get('page') || '1';

    requestFilteredMastersList({ page });
  }

  function addListenersForPagination() {
    const paginationButtons = document.querySelectorAll('div.pagination ul li a');

    paginationButtons.forEach(buttonEl => {
      buttonEl.addEventListener('click', onPaginationPageClick);
    });
  }

  function addHandlerForMastersTableElements() {
    openDropdownTimeLogged();
    comment();
    edit_pm_comment();
    validationTextarea();
    undo();
    checkHeightModalTimeLogged();
    addListenersForPagination();
  }

  function reRenderMastersTable(tableHTML) {
    document.querySelector('#overtime-approve-list').innerHTML = tableHTML;
    addHandlerForMastersTableElements();
  }

  function requestFilteredMastersList(additionalParams = {}) {
    const params = {
      ...getOvertimeApproveFilterParams(),
      ...additionalParams
    };

    window.axios.get('/manager/overtime_approve/search', { params })
      .then(response => reRenderMastersTable(response.data));
  }

  function edit_pm_comment() {
    const checkBtn = document.querySelectorAll('.mm-button-save-pm');
    const desktopOverlay = document.querySelector('.mm-background-overlay');
    const body = document.querySelector('body');

    checkBtn.forEach(i => {
      i.addEventListener('click', () => {
        i.closest('.mm-modal-custom').classList.remove('show-edit-comment');
        i.closest('.mm-modal-custom').classList.add('hide');
        i.closest('.mm-modal-custom').previousElementSibling.children[2].textContent = i.closest('form').children[3].value;
        body.style.overflow = 'auto';
        desktopOverlay.style.display = 'none';
      });
    });
  }
  edit_pm_comment();

  function validationTextarea() {
    $('.edit-comment').keyup(function () {
      if ($(this).val().length <= 1) {
        $('.mm-button-save-pm').attr('disabled', 'disabled');
        $(this).closest('form').children('.error-comment').css('display', 'flex');
        $(this).addClass('error-border');
        $(this).css('border', 'none !important');
      } else {
        $('.mm-button-save-pm').removeAttr('disabled');
        $(this).closest('form').children('.error-comment').css('display', 'none');
        $(this).removeClass('error-border');
        $(this).css('border', '1px solid #e5e5e5 !important');
      }
    });

    $('.overtime__textarea-confirmation').keyup(function () {
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

  document.addEventListener('DOMContentLoaded', () => {
    toggle_button_attribute();
    addFilterEventHandlers();
    addHandlerForMastersTableElements();
  });
}

if (location.pathname.match(/^\/manager\/overtime_approve/i)) {
  overtimeApprove();
}


