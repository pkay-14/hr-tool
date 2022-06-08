(function() {
  var user_id = undefined;
  var curr_question = null;

  function ready() {
    if ($('.candidate').length > 0) {
      user_id = $('.candidate').data('user-id');
    } else if ($('ul.questions-with-answers').length > 0) {
      user_id = $('.user-info').data('user-id');
    }

    if ($('ol.question-list').length > 0 && $('.candidate').data('user-id').length > 0) {
      get_question($('ol.question-list li:first'), $('.candidate').data('user-id'));
    }
  };

  $(document).ready(ready);

  $(document).on('page:load', ready).on('click', '.question-list li', function() {
    if ($('.collapse.in form').size() !== 0) {
      submit_answer($('.collapse.in form'), false);
    }
    $('.collapse.in').collapse('toggle');
    get_question($(this), $('.candidate').data('user-id'));

  }).on('submit', '#new_answer, .edit_answer', function(event) {
    event.preventDefault();
    submit_answer($(this), true);
  }).on('click', '.complete-questionnaire', function(event) {
    event.preventDefault();
    check_user_answers($(this));
  }).on('change', '#user_interview_status', function(event) {
    var interview_el = $('.interview-details');
    if ($(this).val() === 'assigned' || $(this).val() === 'passed') {
      interview_el.removeClass('hidden');
    } else {
      interview_el.addClass('hidden');
    }
  });

  function get_question(curr_li, user_id) {
    $.ajax({
      type: "GET",
      url: "get_question",
      data: {
        question_id: curr_li.data('question-id')
      },
      dataType: 'html'
    }).done(function(data, status, req) {
        if (req === 204..status) {
          alert('Something went wrong');
        } else {
          $('.candidate .answer-wrapper').html(data);
        }
    }).fail(function() {
      alert("There was an error creating the new group.");
    });
  };

  function submit_answer(el, next) {
    if (next == null) {
      next = true;
    }
    console.log(next);
    var valuesToSubmit = el.find('#answer_text').val();
    var question_id = el.closest('.answer-wrapper').data('question-id');
    $.ajax({
      type: "POST",
      url: "send_answer",
      data: {
        question_id: question_id,
        text: valuesToSubmit
      },
      dataType: "json"
    }).done(function(data, status, req) {
      if (req === 204..status) {
        alert('Something went wrong');
      } else {
        var curr_el = $("ol.question-list li[data-question-id = " + question_id + "]");
        var pannel_dafault = curr_el.closest('.panel-default');
        if (!(!valuesToSubmit || $.trim(valuesToSubmit) === "")) {
          curr_el.css('color', 'rgb(5, 73, 5)');
          curr_el.addClass('submited-question');
        }
        console.log(pannel_dafault.next().length + '__' + next);
        if (pannel_dafault.next().length > 0 && next) {
          $('.collapse.in').collapse('toggle');
          pannel_dafault.next().find('.collapse').collapse('toggle');
          get_question(pannel_dafault.next().find('li'), user_id);
        } else if (pannel_dafault.next().length === 0) {
          pannel_dafault.find('.collapse').collapse('toggle');
        }
      }

    }).fail(function() {
      alert("There was an error creating the new group.");
    });

    return false;
  };

  function check_user_answers(link) {
    $.ajax({
      type: "GET",
      url: "check_answers",
      dataType: "json"
    }).done(function(data, status, req) {
      return function(data, status, req) {
        if (req.status === 204) {
          if (confirm('Are you sure you want to finish questionnaire with some empty fields?')) {
            complete_questionnaire(link);
          }
        } else {
          complete_questionnaire(link);
        }
      };
    }).fail(function() {
      alert("There was an error creating the new group.");
    });
    return false;
  };

  function complete_questionnaire(link) {
    $.ajax({
      type: "POST",
      url: link.prop('href'),
      dataType: "json"
    }).done(function(data, status, req) {
      if (req.status === 204) {

      } else {
        // $.fancybox({
        //   href: "#modal .questionnaire-complete",
        //   modal: true,
        //   showCloseButton: true,
        //   overlayColor: '#666'
        // });
      }
    }).fail(function() {
        alert("There was an error creating the new group.");
    });
  };

}).call(this);