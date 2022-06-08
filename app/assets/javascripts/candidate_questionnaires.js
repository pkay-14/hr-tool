(function() {
  function check_qustionnaire_ready() {
    if ($('form[action$=send_questionnaire_for_check]').size() !== 0) {
      check_email($(':selected'));
    }

    $("#employee_id").change(function() {
      check_email($(this));
    });
  };

  function check_email($element) {
    var valuesToSubmit = new Object();
    valuesToSubmit["utf8"] = "✓";
    valuesToSubmit["id"] = $element.val();
    var url = "/admin/candidates/check_email";

    $.ajax({
      url: url,
      type: "POST",
      data: valuesToSubmit,
      dataType: "json",
      statusCode: {
        200: function(data) {
          if (data.status === 'ok') {
            $('input[type=submit]').removeClass('disabled');
            $('.alert-mail').parent().remove();
          } else {
            if ($(".alert").size() === 0) {
              $("#employee_id").closest(".span6").after("<div class=\"span3\" ><div class=\"alert fade in alert-error alert-mail\"><button class=\"close\" data-dismiss=\"alert\">×</button>No Email!</div></div>");
            }
            $('input[type=submit]').addClass('disabled');
            console.log(data.status);
          }
        }
      }
    });
  };

  $(document).on('page:load', check_qustionnaire_ready);

  $(document).ready(check_qustionnaire_ready);

}).call(this);