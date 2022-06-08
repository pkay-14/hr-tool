(function() {
  function ready_questionnaire() {
    $("[data-hint]").popover({
      trigger: "hover",
      placement: "bottom"
    });

    $(".remove-question").bind("ajax:success", function(evt, data, status, xhr) {
      var $elem;
      $elem = $(this).parent().parent();
      $elem.fadeOut(300, function() {
        $elem.remove();
      });
    });

    hide_filter_options();

    $('#questionnaires .dropdown-menu li').on("click", function(e) {
      e.preventDefault();
      var toggleLink = $(this).parent().siblings('[data-toggle="dropdown"]');
      $('#questionnaires .dropdown-menu li.active').removeClass("active");
      $(this).parent().find('.hide').removeClass('hide');
      $(this).addClass('hide');
      $(this).prev().addClass('hide');
      toggleLink.contents().first()[0].nodeValue = $(this).text();
      toggleLink.attr("data-current-questionnaires", $(this).attr("data-tech"));
    });

    $(".open-question-form").on('click', function(e) {
      e.preventDefault();
      $(".open-question-form").parent().addClass("hide");
      $("#questionnaires .new-question-form").removeClass("hide");
    });

    $(".cancel-adding, .add-question").on('click', function() {
      $(".open-question-form").parent().removeClass("hide");
      $("#questionnaires .new-question-form").addClass("hide");
    });
  };

  function hide_filter_options() {
    $('#question-filters .dropdown-menu li').first().addClass('hide');
    $('#question-filters .dropdown-menu li').first().next().addClass('hide');
  };

  $(document).ready(ready_questionnaire);

  $(document).on('page:load', ready_questionnaire);
}).call(this);