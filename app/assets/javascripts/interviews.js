(function() {
  var date_el = null;
  var status_el = null;
  var reject_reason_el = null;
  var interview_wrapper = null;
  var feedback_wrapper = null;
  var feedback = null;

  function ready() {
    $('[data-hint]').popover({
      trigger: 'hover',
      placement: 'bottom'
    });

    date_el = $('.interview-date');
    status_el = $('.interview-status');
    reject_reason_el = $('.reject-reason');
    feedback = $('.hr-comment');
    interview_wrapper = $('.interviewer-wrapper');
    feedback_wrapper = $('.feedback-wrapper');

    $('.interviews-filter label').click(function(e) {
      e.preventDefault();
      $(this).toggleClass('active');
    });

    changeStatus();


    status_el.bind('change', changeStatus);

    if ($('form[action$=set_interviewers]').size() !== 0) {
      $(':checkbox:checked').each(function() {
        check_email($(this));
      });
    }

    $(':checkbox[name^=interviewers]').change(function() {
      if ($(this).is(':checked')) {
        check_email($(this));
      } else {
        $(this).parent().find('.alert-interviewer-right').remove();
      }

      if ($('.alert-interviewer-right').size() === 0) {
        $('input[value=Send]').removeClass('disabled');
        $('input[value=Send]').removeAttr('disabled');
      }
    });
  }

  $(document).ready(ready);

  $(document).on('page:load', ready);

  function changeStatus() {
    var status = $('.interview-status').val();
    var no_email = $('.no-email-interview');

    if (status === 'rejected') {
      date_el.val('').closest('li').addClass('hidden');
      reject_reason_el.closest('li').removeClass('hidden');
      feedback.closest('li').addClass('hidden');
      feedback_wrapper.addClass('hidden');
    } else if (status === 'passed') {
      reject_reason_el.closest('li').addClass('hidden');
      date_el.closest('li').removeClass('hidden');
      feedback.closest('li').removeClass('hidden');
      feedback_wrapper.removeClass('hidden');
    } else {
      date_el.closest('li').removeClass('hidden');
      reject_reason_el.closest('li').addClass('hidden');
      feedback.closest('li').addClass('hidden');
      feedback_wrapper.addClass('hidden');

      if (status === 'none') {
        date_el.val('').closest('li').addClass('hidden');
      }
    }

    if (status !== 'assigned') {
      interview_wrapper.addClass('hidden');
      no_email.addClass('hidden');
    } else {
      no_email.removeClass('hidden');
      interview_wrapper.removeClass('hidden');
      console.log('assigned');

      $('.submit-interview').on('click', function() {
        console.log('aaa');
        check_date_interview();
      });
    }
  }

  function check_date_interview() {
    console.log('start');
    if ($('.interview-status').val() === 'assigned' && $('.interview-date').val() === '') {
      if ($('.alert-interview-nodate').size() === 0) {
        $('.candidate-link>.btn-default').after('<div class=\"alert fade in alert-error alert-interview-nodate\">Please, choose date</div>');
      }
      return false;
    }
  }

  function check_email($element) {
    var url, valuesToSubmit;

    valuesToSubmit = new Object();
    valuesToSubmit.utf8 = '✓';
    valuesToSubmit.id = $element.val();
    url = '/admin/candidates/check_email';
    return $.ajax({
      url: url,
      type: 'POST',
      data: valuesToSubmit,
      dataType: 'json',
      statusCode: {
        200: function(data) {
          if (data.status === 'ok') {
            r$element.parent().find('.alert-interviewer-right').remove();
          } else {
            if ($element.parent().find('.alert-interviewer-right').size() === 0) {
              $element.next().after('<div class=\"alert fade in alert-error alert-interviewer-right\">No Email!</div>');
            }

            $('input[value=Send]').addClass('disabled');
            $('input[value=Send]').attr('disabled', 'disabled');
          }
        }
      }
    });
  }

  function validationDateField() {
    if ($('#master_interview_date').val().length <= 9 ) {
      $('.add-interview').attr('disabled', 'disabled');
    } else {
      $('.add-interview').removeAttr('disabled');
    }
  }

  function checkDateField() {
    $('.add-interview').attr('disabled', 'disabled');
    $('#master_interview_date').on('keyup', function () {
      $(this).val($(this).val().replace (/[^0-9.: ]+/, ''));
      validationDateField();
    });

    $('#interview-date').datetimepicker().on('changeDate', function () {
      validationDateField();
    });
  }

  $(document).on('page:load', checkDateField).ready(checkDateField);
}).call(this);
