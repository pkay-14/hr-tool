(function() {
  var monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  var timer = undefined;

  var calendar_ready = function() {
    $('.imployee-info i').click(function() {
      $(this).closest('tr').nextUntil('[data-main=\'info\']').toggleClass('hide-calendar-employee-projects');
      $(this).toggleClass('icon-caret-down icon-caret-up');
    });

    $('#month-year-right').click(function() {
      change_date(1);
    });

    $('#month-year-left').click(function() {
      change_date(-1);
    });

    $('#calendar .dropdown-menu li').on('click', function(e) {
      var toggleLink;

      e.preventDefault();
      var self = $(this);

      self.parent().find('.hide').removeClass('hide');
      self.addClass('hide');

      if (self.is('[data-tech]')) {
        toggleLink = $('[data-current-tech]');
        toggleLink.attr('data-current-tech', self.attr('data-tech'));
      } else if (self.is('[data-status]')) {
        toggleLink = $('[data-current-status]');
        toggleLink.attr('data-current-status', self.attr('data-status'));
      } else if (self.is('[data-project-category]')) {
        toggleLink = $('[data-current-project-category]');
        toggleLink.attr('data-current-project-category', self.attr('data-project-category'));
      } else if (self.is('[data-company-division]')) {
        toggleLink = $('[data-current-company-division]');
        toggleLink.attr('data-current-company-division', self.attr('data-company-division'));
      } else if (self.is('[data-community]')) {
        toggleLink = $('[data-current-community]');
        toggleLink.attr('data-current-community', self.attr('data-community'));
      } else if (self.is('[data-position]')) {
        toggleLink = $('[data-current-position]');
        toggleLink.attr('data-current-position', self.attr('data-position'));
      } else if (self.is('[data-filter]')) {
        toggleLink = $('[data-current-master-cabinet-filter]');
        toggleLink.attr('data-current-master-cabinet-filter', self.attr('data-filter'));
      } else if (self.is('[data-team]')) {
        toggleLink = $('[data-current-team]');
        toggleLink.attr('data-current-team', self.attr('data-team'));
      }

      toggleLink.text(self.text());
    });

    var current_day = $('table th.current-day');
    var current_day_index = current_day.index();

    current_day.closest('table').find(`td:nth-child(${current_day_index + 1})`).addClass('current-day');

    $('.load-indicator').popover();

    hide_filter_options();

    calendar_filters();

    $('.spinner').hide();

    if (typeof gon !== 'undefined' && gon.init_load_calendar === true) {
      calendar_filters_request();
    }

    resetStorage();
  };

  function calendar_filters() {
    var oldSearchFieldVal;

    $('#calendar li[data-tech], #calendar li[data-status], #calendar li[data-project-category]' +
        ', #calendar li[data-company-division], #calendar li[data-community], #calendar li[data-position]' +
        ', #calendar li[data-filter], #calendar li[data-team]').on('click', function(e) {
      calendar_filters_request();
    });

    $('#calendar #search-item').on('change keyup paste propertychange', function(e) {
      var query = $('#calendar #search-item input').val();

      if (query !== oldSearchFieldVal) {
        if (query.length >= 3 || query.length === 0) {
          calendar_filters_request();
          oldSearchFieldVal = query;
        }
      }
    });

    $('#month-year-left, #month-year-right').on('click', function(e) {
      calendar_filters_request();
    });

    $('#calendar .items-on-page').on('change', function(e) {
      calendar_filters_request();
    });

    $('#calendar .current-day-heightlight').on('click', function(e) {
      var currentDate = new Date();

      $('#calendar time').attr('datetime', format_date(currentDate));
      $('#calendar time').html(`${monthNames[currentDate.getMonth()]} ${currentDate.getFullYear()}`);
      calendar_filters_request();
    });
  }

  function request() {
    var params = calendar_filters_params();

    $.ajax({
      url: '/manager/calendar/search',
      type: 'GET',
      data: params
    }).done(function () {
      highlightOption();
    });
  }

  function calendar_filters_request() {
    var time;

    if (gon.init_load_calendar === true) {
      gon.init_load_calendar = false;
      time = 50;
    } else {
      time = 1500;
    }
    clearTimeout(timer);
    timer = setTimeout(request, time);
  }

  function calendar_filters_params() {
    return {
      project_category: $('a[data-current-project-category]').text().trim(),
      tech: $('a[data-current-tech]').text().trim(),
      load_status: $('a[data-current-status]').text().trim(),
      company_division: $('a[data-current-company-division]').text().trim(),
      community: $('a[data-current-community]').text().trim(),
      position: $('a[data-current-position]').text().trim(),
      team: $('a[data-current-team]').text().trim(),
      search_query: $('#calendar #search-item input').val(),
      date: $('#calendar time').attr('datetime'),
      per_page: $('#calendar .items-on-page').val(),
      master: $('.master-cabinet').data('master-cabinet').toString(),
      teammates: $('[data-current-master-cabinet-filter]').text().trim() === 'Team\'s'
    };
  }


  function change_date(month) {
    var dateAttr = $('#calendar time').attr('datetime');
    var currentDate = new Date(dateAttr);

    currentDate.setDate(15);
    currentDate.setMonth(currentDate.getMonth() + month);
    var today = new Date();

    if (currentDate.getMonth() === today.getMonth()) {
      currentDate.setDate(today.getDate());
    }

    $('#calendar time').attr('datetime', format_date(currentDate));
    $('#calendar time').html(`${monthNames[currentDate.getMonth()]} ${currentDate.getFullYear()}`);
  }

  function hide_filter_options() {
    $('#project-category-filters .dropdown-menu li').first().addClass('hide');
    $('#tech-filters .dropdown-menu li').first().addClass('hide');
    $('#status-filters .dropdown-menu li').first().addClass('hide');
    $('#company-division-filters .dropdown-menu li').first().addClass('hide');
    $('#community-filters .dropdown-menu li').first().addClass('hide');
    $('#position-filters .dropdown-menu li').first().addClass('hide');
    $('#master-cabinet-filters .dropdown-menu li').first().addClass('hide');
    $('#team-filters .dropdown-menu li').first().addClass('hide');
  }

  function format_date(date) {
    var dateString;

    dateString = `${date.getFullYear()}-${(`0${date.getMonth() + 1}`).slice(-2)}-${date.getDate()}`;
    return dateString;
  }

  function resetStorage() {
    if (!location.pathname.includes('/manager/calendar')) {
      localStorage.removeItem('name');
      localStorage.removeItem('total');
    }
  }

  $(document).on('page:load', calendar_ready).ready(calendar_ready);
}).call(this);
