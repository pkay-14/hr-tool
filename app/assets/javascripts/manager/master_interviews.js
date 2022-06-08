(function() {
  function master_interviews_filters() {
    $('#master_interviews li[data-status], #master_interviews li[data-successful-status]').on("click", function() {
      master_interviews_filters_request();
    });
  };

  function master_interviews_filters_request() {
    var params = master_interviews_filters_params();

    $.ajax({
      url: "/manager/master_interviews/search",
      type: "GET",
      data: params
    });
  };

  function master_interviews_filters_params() {
    var data;
    data = {};
    data['user_id'] = $('#user_id').val();
    data['status'] = $('[data-current-status]').attr('data-current-status');
    data['successful_status'] = $('[data-current-successful-status]').attr('data-current-successful-status');
    return data;
  };

  function master_interviews_ready() {
    $('#master_interviews .dropdown-menu li').on("click", function(e) {
      var toggleLink;
      e.preventDefault();
      var self = $(this);
      self.parent().find('.hide').removeClass('hide');
      self.addClass('hide');

      if (self.is('[data-status]')) {
        toggleLink = $('[data-current-status]');
        toggleLink.attr('data-current-status', self.attr('data-status'));
      } else if (self.is('[data-successful-status]')) {
        toggleLink = $('[data-current-successful-status]');
        toggleLink.attr('data-current-successful-status', self.attr('data-successful-status'));
      }

      toggleLink.text(self.text());
    });

    master_interviews_filters();
    hide_filter_options();
  };

  function hide_filter_options() {
    $('#interviews-filters .dropdown-menu li').first().addClass('hide');
    $('#interviews-success .dropdown-menu li').first().addClass('hide');
  };

  $(document).on('page:load', master_interviews_ready).ready(master_interviews_ready);
}).call(this);
