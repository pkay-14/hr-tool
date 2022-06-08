function projectsLocalScope() {
  var timer = null;

  function clear_date_events() {
    $('[data-load-id] .clear').on('click', function() {
      var data = {
        load: {}
      };
      var load_id = $(this).closest('[data-load-id]').data('load-id');

      if ($(this).parent().hasClass('from-date')) {
        data.date = 'from';
      } else {
        data.date = 'to';
      }

      $.ajax({
        url: `/manager/projects/load/${load_id}/clear_date`,
        type: 'POST',
        data: data
      }).done(function () {
        $(this).closest('td').children('.date-text').remove();
      });
    });
    $('.member-row .from-date .clear').on('click', function () {
      $(this).closest('td').children('.clear').hide();
    });

    $('.member-row .to-date .clear').on('click', function () {
      $(this).closest('td').children('.clear').hide();
    });
  }

  function projects_filters() {
    $('#projects li[data-manager], #projects li[data-status]').on('click', function(e) {
      sortingSandbox.resetSortinOrder();
      projects_filters_request();
    });

    $('#projects .search-form input').on('change keyup paste propertychange', function(e) {
      clearTimeout(timer);
      timer = setTimeout(projects_filters_request, 1500);
    });

    $('#projects .items-on-page').on('change', function(e) {
      projects_filters_request();
    });
  }

  function projects_filters_request() {
    var params = projects_filters_params();

    $.ajax({
      url: '/manager/projects/search',
      type: 'GET',
      data: params
    }).done(function () {
      highlightOption();
      checkTooltipText();
    });
  }

  function projects_filters_params() {
    var data;

    data = {};
    data.manager_id = $('[data-current-manager]').attr('data-current-manager');
    data.status = $('[data-current-status]').attr('data-current-status');
    data.search_query = $('#projects .search-form input').val();
    data.per_page = $('#projects .items-on-page').val();
    return data;
  }

  function project_loads_datepicker(id) {
    $(`[data-project-members=${id}] .from-date, [data-project-members=${id}] .to-date`).datetimepicker({
      pickTime: false,
      weekStart: 1
    }).on('changeDate', function() {
      const self = $(this);
      const dateField = document.createElement('span');
      const date_value = self.find('input').val();
      const load_id = self.closest('[data-load-id]').data('load-id');
      let data;

      self.find('.date-field').remove();
      self.find('.date-text').remove();
      self.find('.clear').remove();
      dateField.classList.add('date-text');
      self.append(dateField);
      self.datetimepicker('hide');
      self.find('.date-text').text(date_value);

      if (self.hasClass('from-date')) {
        data = {
          load: {
            from: date_value
          }
        };
      } else {
        data = {
          load: {
            to: date_value
          }
        };
      }

      $.ajax({
        url: `/manager/projects/load/${load_id}`,
        type: 'PUT',
        data: data
      });

      $.ajax({
        url: `projects/load/${load_id}/warning`,
        type: 'GET',
        data: {}
      });
      clear_date_events();
    });
    clear_date_events();
  }

  function createDeleteButton(id) {
    $(`[data-project-members=${id}] .to-date`).datetimepicker({
      pickTime: false,
      weekStart: 1
    }).on('changeDate', function() {
      const self = $(this);
      const clearField = document.createElement('button');

      clearField.classList.add('clear');
      self.append(clearField);
      clear_date_events();
    });
  }

  function add_tag() {
    var $search_input, $self;

    $search_input = $('input[name=search_query]');
    $self = $(this);
    $search_input.val(`${$search_input.val()} ${$self.text()}`);
    projects_filters_request();
  }

  function hide_tags_list() {
    $('.search-form .tag-links').popover('hide');
  }

  function hide_filter_options() {
    $('#project-status-filters .dropdown-menu li').first().addClass('hide');
    // $('#project-status-filters .dropdown-menu li').first().next().addClass('hide');
  }

  function showFromEmptyError(show = false) {
    if (show) {
      $('#add-project-popup--date--error-required').css('display', 'block');
      $('#add-project-popup--date--container').addClass('error-border');
    } else {
      $('#add-project-popup--date--error-required').css('display', 'none');
      $('#add-project-popup--date--container').removeClass('error-border');
    }
  }

  function isNewProjectFromValid() {
    return !!document.querySelector('[data-start-date-proj-new]')?.value.length;
  }

  function project_ready() {
    $('.search-form .tag-links').popover({
      placement: 'bottom',
      html: true,
      content: function() {
        $(this).parent().find('#tags').html();
      }
    });

    $('[data-hint]').popover({
      trigger: 'hover',
      placement: 'bottom'
    });

    $('#projects .comment-icon').on('click', function(e) {
      e.preventDefault();
      var project_id = $(this).closest('.project-row').find('[data-expand-project-id]').attr('data-expand-project-id');

      $.ajax({
        url: `/manager/projects/${project_id}/send_for_feedbacks`,
        type: 'POST',
        data: {}
      });
    });

    $('.open-all-project-form').on('click', function() {
      if ($('#projects .member-row').length && $('#projects .member-row').hasClass('hide')) {
        $('#projects .member-row').removeClass('hide');
        $('.open-all-project-form').toggleClass('hideProject');
        $('[data-expand-project-id]').each(function() {
          var projectId = $(this).data('expandProjectId');

          project_loads_datepicker(projectId);
          createDeleteButton(projectId);
        });
      } else {
        $('#projects .member-row').addClass('hide');
        $('.open-all-project-form').toggleClass('hideProject');
      }
    });

    $('[data-expand-project-id]').on('click', function(e) {
      if (e.target.tagName === 'A') {
        return;
      }

      var projectId = $(this).data('expandProjectId');

      $(`[data-project-members = ${projectId}]`).toggleClass('hide');
      project_loads_datepicker(projectId);
      createDeleteButton(projectId);
      var allMemberRows = $('#projects .member-row').length;
      var hideMemberRows = $('#projects .member-row.hide').length;
      var shownMemberRows = $('#projects .member-row').not('.hide').length;

      if ((allMemberRows === hideMemberRows && hideMemberRows === shownMemberRows)) {
        $('.open-all-project-form').addClass('hideProject');
      } else {
        $('.open-all-project-form').removeClass('hideProject');
      }

      var caret = $(this).children('i');

      if ($(`[data-project-members = ${projectId}]`).hasClass('hide')) {
        caret.addClass('projects-icon-caret-down').removeClass('projects-icon-caret-up');
      } else {
        caret.removeClass('projects-icon-caret-down').addClass('projects-icon-caret-up');
      }
    });

    function returnStyleInputProjectName() {
      $('#add-project-popup--project-name--error-name-duplicated').css('display', 'none');
      $('.new-project-form__input-name').removeClass('field_with_errors').css('marginBottom', '10px');
    }

    $('.open-project-form').on('click', function () {
      returnStyleInputProjectName();
      showFromEmptyError(false);
    });

    $('.new-project-form__input').on('keyup', function () {
      returnStyleInputProjectName();
    });

    document.querySelector('#add-project-form-submit-btn')?.addEventListener('click', function(event) {
      var form = $(this).closest('form');

      if (!isNewProjectFromValid()) {
        event.preventDefault();
        showFromEmptyError(true);
        return;
      }
      showFromEmptyError(false);

      form.submit();
      form[0].reset();
      projects_filters_request();
      return false;
    });

    // TODO: change to openPopup func, get rid of $
    // Ticket: https://mocglobal.atlassian.net/browse/MM-673
    $('.btn-remove-master').on('click', function () {
      const parentRowEl = this.closest('[data-project-members]');
      const tableNameEl = parentRowEl.querySelector('[data-master-name]');
      const popupNameEl = document.querySelector('[data-deleting-name]');

      popupNameEl.textContent = `${tableNameEl.textContent}'s`;
      $('.master-remove-icon').attr('data-load-id', $(this).attr('data-load-id'));
      $('#confirm-modal-master').css('display', 'block');
      $('.mm-background-overlay').css('display', 'block');
    });
    $('.master-remove-icon').on('click', function () {
      var load_id = $(this).attr('data-load-id');

      $.ajax({ url: `/manager/projects/load/${load_id}`, type: 'DELETE', data: {} }).done(function () {
        $(`tr[data-load-id="${load_id}"]`).remove();
        $('.mm-background-overlay').css('display', 'none');
      });
    });

    hide_filter_options();

    $('#projects .dropdown-menu li').on('click', function(e) {
      e.preventDefault();
      var toggleLink = $(this).parent().siblings('[data-toggle="dropdown"]');

      $('#projects .dropdown-menu li.active').removeClass('active');
      $(this).parent().find('.hide').removeClass('hide');
      $(this).addClass('hide');
      // $(this).prev().addClass('hide');
      toggleLink.contents().first()[0].nodeValue = $(this).text();

      if (toggleLink.is('[data-current-manager]')) {
        toggleLink.attr('data-current-manager', $(this).attr('data-manager'));
      }
      if (toggleLink.is('[data-current-status]')) {
        toggleLink.attr('data-current-status', $(this).attr('data-status'));
      }
    });

    $('.project-row .from-date, .project-row .to-date').datetimepicker({
      pickTime: false,
      weekStart: 1
    }).on('changeDate', function(ev) {
      var data;
      var self = $(this);

      self.find('.date-text').remove();
      self.find('.clear').remove();
      var dateField = document.createElement('span');
      var clearField = document.createElement('button');

      dateField.classList.add('date-text');
      clearField.classList.add('clear');
      self.append(dateField);
      self.append(clearField);
      self.datetimepicker('hide');
      var date_value = self.find('input').val();
      var project_id = self.parent().find('[data-expand-project-id]').data('expand-project-id');

      self.find('.date-text').text(date_value);

      if (self.hasClass('from-date')) {
        data = {
          project: {
            from: date_value
          }
        };
      } else {
        data = {
          project: {
            to: date_value
          }
        };
      }

      $.ajax({
        url: `/manager/projects/${project_id}`,
        type: 'PUT',
        data: data
      });
      removeDateProject();
    });
    removeDateProject();


    function onDatePickerChangeProjects() {
      var datepicker = $('[data-datepicker-proj]').datetimepicker({
        pickTime: false,
        format: 'dd-MM-yyyy'
      });

      function addClearBtn(i) {
        var datepickerField = i.datetimepicker({
          pickTime: false,
          format: 'dd-MM-yyyy'
        });

        datepickerField.on('changeDate', function () {
          datepickerField.children('.clear-date').css('display', 'block');
        });
      }

      addClearBtn($('[data-current-datepicker-proj]'));
      addClearBtn($('[data-launch-datepicker-proj]'));

      datepicker.on('changeDate', function(ev) {
        var startDateInp = $('[data-start-date-proj]');
        var endDateInp = $('[data-end-date-proj]');

        if (startDateInp.val().length > 0 && endDateInp.val().length > 0) {
          var startDate = new Date(startDateInp.val());
          var endDate = new Date(endDateInp.val());

          if (endDate < startDate) {
            $('#add-project-form-submit-btn').attr('disabled', 'disabled');
            $('.mm-button-update-project').attr('disabled', 'disabled');
            $('.error-date-massage-projects__item').show();
          } else {
            $('#add-project-form-submit-btn').removeAttr('disabled');
            $('.error-date-massage-projects__item').hide();
            $('.mm-button-update-project').removeAttr('disabled');
          }
        }
      });
    }

    function onDatePickerChangeNewProjects() {
      var datepicker = $('[data-datepicker-proj-new]').datetimepicker({
        pickTime: false,
        format: 'dd.MM.yyyy'
      });

      datepicker.on('changeDate', function(ev) {
        var startDatepicker = $('[data-current-datepicker-proj-new]');
        var endDatepicker = $('[data-launch-datepicker-proj-new]');
        var startDateInp = $('[data-start-date-proj-new]');
        var endDateInp = $('[data-end-date-proj-new]');

        if (isNewProjectFromValid()) {
          showFromEmptyError(false);
        }

        if (startDateInp.val().length > 0 && endDateInp.val().length > 0) {
          var startDate = new Date(startDatepicker.data('datetimepicker').getDate());
          var endDate = new Date(endDatepicker.data('datetimepicker').getDate());

          if (endDate < startDate) {
            $('#add-project-form-submit-btn').attr('disabled', 'disabled');
            $('.mm-button-update-project').attr('disabled', 'disabled');
            $('.error-date-massage-projects__item').show();
          } else {
            $('#add-project-form-submit-btn').removeAttr('disabled');
            $('.error-date-massage-projects__item').hide();
            $('.mm-button-update-project').removeAttr('disabled');
          }
        }

        if (startDateInp.val().length === 0 || endDateInp.val().length === 0) {
          $('#add-project-form-submit-btn').removeAttr('disabled');
          $('.error-date-massage-projects__item').hide();
          $('.mm-button-update-project').removeAttr('disabled');
        }
      });

      datepicker.on('keyup', function () {
        var startDateInp = $('[data-start-date-proj-new]');
        var endDateInp = $('[data-end-date-proj-new]');

        if (startDateInp.val().length === 0 || endDateInp.val().length === 0) {
          $('#add-project-form-submit-btn').removeAttr('disabled');
          $('.error-date-massage-projects__item').hide();
          $('.mm-button-update-project').removeAttr('disabled');
        } else {
          $('#add-project-form-submit-btn').attr('disabled', 'disabled');
          $('.mm-button-update-project').attr('disabled', 'disabled');
          $('.error-date-massage-projects__item').show();
        }
      });
    }

    function clearProjectDate(dateField) {
      var clearDateBtn = document.querySelectorAll('.clear-date');

      clearDateBtn.forEach(function (i) {
        i.addEventListener('click', function () {
          i.closest('div').children[1].value = '';
          $('.mm-button-update-project').removeAttr('disabled');
          $('.error-date-massage-projects__item').hide();
          i.style.display = 'none';
        });
        if (dateField.value.length === 0 || dateField.value.length === 0) {
          dateField.closest('div').children[0].style.display = 'none';
        }
      });
    }

    function clearProjectDates() {
      var startDateProj = document.querySelector('[data-start-date-proj]');
      var endDateProj = document.querySelector('[data-end-date-proj]');

      clearProjectDate(startDateProj);
      clearProjectDate(endDateProj);
    }


    $(document).on('page:load', onDatePickerChangeProjects).ready(onDatePickerChangeProjects);
    $(document).on('page:load', onDatePickerChangeNewProjects).ready(onDatePickerChangeNewProjects);
    $(document).on('page:load', clearProjectDates).ready(clearProjectDates);
    $(document).on('page:load', checkTooltipText).ready(checkTooltipText);

    $('#projects-wrap').sortable({
      items: 'tr.project-row',
      placeholder: 'emptySpace',
      helper: 'clone',
      update: function(event, ui) {
        $('[data-expand-project-id]').each(function() {
          var project_id = $(this).attr('data-expand-project-id');
          var project_row = $(`[data-expand-project-id=${project_id}]`).parent();

          $(`[data-project-members=${project_id}]`).insertAfter(project_row);
        });

        $('.save-proj-bt').removeClass('hide');

        var data = {};

        data.projects = {};

        $('#projects-wrap tr.project-row').each(function() {
          var project_id = $(this).find('[data-expand-project-id]').attr('data-expand-project-id');
          var index = +$(this).index();

          data.projects[project_id] = index;
        });

        $.ajax({
          url: 'projects/update_positions',
          type: 'POST',
          data: data
        });
      }
    });

    projects_filters();

    $('.best_in_place').best_in_place();

    $('.member-load .best_in_place').best_in_place().bind('ajax:success', function() {
      var load_id = $(this).data('loadId');

      $.ajax({
        url: `projects/load/${load_id}/warning`,
        type: 'GET',
        data: {}
      });
    });

    $('[data-user-list="initail"]').on('select2:select', function(e) {
      $(this).parent().siblings('.st-member-name').text(e.params.data.text).show();
      var master_id = e.params.data.id;
      var load_id = $(this).closest('[data-load-id]').attr('data-load-id');

      $.ajax({
        url: `/manager/projects/load/${load_id}`,
        type: 'PUT',
        data: {
          load: {
            employee_id: master_id
          }
        }
      });

      $.ajax({
        url: `projects/load/${load_id}/warning`,
        type: 'GET',
        data: {}
      });
    });

    $('[data-user-list="initail"]').on('select2:opening', function(e) {
      $(this).parent().siblings('.st-member-name').hide();
      $(this).parent().removeClass('hidden');
    });

    $('[data-user-list="initail"]').on('select2:close', function(e) {
      $(this).parent().addClass('hidden');
      $(this).parent().siblings('.st-member-name').show();
    });

    $('.st-member-name').on('click', function(e) {
      $(this).siblings('.select-wrapper').find('[data-user-list="initail"]').select2('open');
    });


    function removeDateProject () {
      $('.project-row .from-date .clear, .project-row .to-date .clear').on('click', function() {
        var data = {
          project: {}
        };

        var project_id = $(this).closest('.project-row').find('[data-expand-project-id]').attr('data-expand-project-id');

        if ($(this).parent().hasClass('from-date')) {
          data.date = 'from';
        } else {
          data.date = 'to';
        }

        $.ajax({
          url: `/manager/projects/${project_id}/clear_date`,
          type: 'POST',
          data: data
        }).done(function () {
          $(this).closest('td').children('.date-text').remove();
        });
      });
      $('.project-row .from-date .clear').on('click', function () {
        $(this).closest('td').children('.clear').hide();
      });
      $('.project-row .to-date .clear').on('click', function () {
        $(this).closest('td').children('.clear').hide();
      });
    }

    $('[data-sorting-control]').on('click', function() {
      var reqRout = '/manager/projects/search';
      var payload = {
        manager_id: $('[data-current-manager]').attr('data-current-manager'),
        status: $('[data-current-status]').attr('data-current-status'),
        search_query: $('#projects .search-form input').val(),
        per_page: $('#projects .items-on-page').val()
      };

      sortingSandbox.sort(reqRout, payload);
    });

    $.ajax({
      url: '/admin/employees/employee_for_projects',
      type: 'GET',
      data: {},
      success: function (result) {
        return $('[data-user-list="initail"]').select2({
          data: result
        });
      }
    });

    function projectsFiltersParamsForCSV() {
      return {
        manager_id: $('[data-current-manager]').attr('data-current-manager'),
        status: $('[data-current-status]').attr('data-current-status'),
        search_query: $('#projects .search-form input').val(),
        per_page: $('#projects .items-on-page').val(),
        status_order:  $('[data-sorting-icon]').attr('data-projects-sorting')
      };
    }

    function exportFilteredProjectsBtnClickHandler() {
      const requestUrl = `/manager/projects/export?${new URLSearchParams(projectsFiltersParamsForCSV())}`;

      fetch(requestUrl, {
        method: 'GET',
        headers: window.addCsrfTokenToRequestHeaders(new Headers())
      }).then(response => response.blob())
        .then((responseBlob) => {
          const link = document.createElement('a');

          link.href = window.URL.createObjectURL(responseBlob);
          link.download = 'Project Data.csv';
          link.click();
          link.remove();
        });
    }

    (function addLogicToExportFilteredProjectsBtnClickHandler() {
      const btn = document.querySelector('#export-filtered-projects--btn');

      if (btn) {
        btn.addEventListener('click', exportFilteredProjectsBtnClickHandler);
      }
    })();
  }

  $(document).on('page:load', project_ready).on('click', '#tags_list a', add_tag).on('mouseleave', '.popover', hide_tags_list).ready(project_ready);

  $(document).on('click', '[data-projects-delete] #delete-item', function() {
    var project_id = $('#delete-item').attr('data-expand-project-id');

    $('#confirm-modal').hide();
    $('body').removeClass('modal-open');
    $('.modal-backdrop').addClass('loader');
    $.ajax({
      url: `/manager/projects/${project_id}`,
      type: 'DELETE',
      data: {}
    }).done(function() {});
    $('.modal-backdrop').fadeOut('slow');
    projects_filters_request();
    $('[data-expand-project-id]').closest('tr').remove();
    $('#confirm-modal-project').css('display', 'none');
    $('.mm-background-overlay').css('display', 'none');
  });

  $(document).on('click', '.close-project-modal', function() {
    $('#confirm-modal-project').css('display', 'none');
    $('#confirm-modal-master').css('display', 'none');
    $('.mm-background-overlay').css('display', 'none');
  });

  $(document).on('click', '[data-delete-project]', function() {
    var project_id = $(this).closest('.project-row').find('[data-expand-project-id]').attr('data-expand-project-id');

    $('#delete-item').attr('data-expand-project-id', project_id);
    $('#confirm-modal-project').css('display', 'block');
    $('.mm-background-overlay').css('display', 'block');
  });

  function checkTooltipText() {
    const tooltipTextEls = document.querySelectorAll('[data-master-tooltip-text]');

    tooltipTextEls.forEach(tooltipTextEl => {
      if (tooltipTextEl.textContent.trim().length === 0) {
        tooltipTextEl.closest('[data-master-tooltip]').style.visibility = 'hidden';
      }
    });
  }
}

if (location.pathname.match(/manager\/projects/)) {
  projectsLocalScope.call(this);
}

