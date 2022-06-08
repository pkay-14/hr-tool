(function() {
  function task_ready() {
    $.datepicker.setDefaults({
      dateFormat: 'yy-mm-dd'
    });

    change_mode($(".test-task-mode :checked").val());

    $(".test-task-mode input[name^='mode']").click(function() {
      test_mode_ajax($(this).val());
    });

    $('.sent_date , .recieved_date').bind("ajax:success", function(evt, data, status, xhr) {
      change_status();
    });

    $('.test-task-answer-field').bind("ajax:success", function(evt, data, status, xhr) {
      $('.mode .automatic ul>li').find('dd').text($('.test-task-answer-field').text());
    });
  };

  function change_status() {
    var val = $.trim($('.test-task').text().split(':')[1]);
    if ($('.recieved_date').text() !== "Click me to assign date!" && $('.recieved_date').text() !== "") {
      if (val !== "finished") {
        test_status_ajax("finished");
      }
    } else if ($('.sent_date').text() !== "Click me to assign date!" && $('.sent_date').text() !== "") {
      if (val !== "sent") {
        test_status_ajax("sent");
      }
    } else {
      test_status_ajax("not sent");
    }
  };

  function change_mode(val) {
    if (val === 'Automatic') {
      $('.mode .automatic, .automatic-btn').css("display", "block");
      $('.mode .manually').css("display", "none");
    } else {
      $('.mode .automatic,.automatic-btn').css("display", "none");
      $('.mode .manually').css("display", "block");
    }
  };

  function test_status_ajax(val) {
    $.ajax({
      type: "PATCH",
      url: "test_task",
      data: {
        task: {
          status: val
        }
      },
      dataType: 'html'
    }).done(function(data, status, req) {
      $('.test-task').text('Test task status: ' + val);
      if (req === 204..status) {
        alert('Something went wrong');
      }
    });
  };

  function test_mode_ajax(val) {
    $.ajax({
      type: "PATCH",
      url: "test_task",
      data: {
        task: {
          mode: val
        }
      },
      dataType: 'html'
    }).done(function(data, status, req) {
      change_mode(val);
      if (req === 204..status) {
        return alert('Something went wrong');
      }
    });
  };

  $(document).on('page:load', task_ready).ready(task_ready);
}).call(this);