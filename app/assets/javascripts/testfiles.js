(function() {
  function remove_attachment() {
    $(".remove-attachment").bind("ajax:success", function(evt, data, status, xhr) {
      $(this).parent().remove();
    });
  };

  function upload_test_files($uploadList, $dropzone, $fileupload) {
    var formatFileSize;
    formatFileSize = undefined;
    formatFileSize = undefined;
    $uploadList = $uploadList.find(".upload-list");

    $dropzone.find(".browse").click(function() {
      $fileupload.click();
    });

    $fileupload.fileupload({
      dataType: "json",
      dropZone: $dropzone,
      add: function(e, data) {
        var jqXHR = undefined;
        var tpl = undefined;
        jqXHR = undefined;
        tpl = undefined;
        console.log($('.complete'));
        tpl = $("<li class=\"working\"><div class=\"uploaded-progress\"><p></p><div class=\"progress\"><div class=\"progress-bar\" role=\"progressbar\" aria-valuenow=\"0\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width: 60%;\"><span class=\"sr-only\">60% Complete</span></div></div></div><span></span></li>");
        tpl.find("p").text(data.files[0].name).append("<i>  ->" + formatFileSize(data.files[0].size) + "</i> -> ");
        data.context = tpl.appendTo($uploadList);

        jqXHR = data.submit();
      },
      progress: function(e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        data.context.find(".progress-bar").width(progress + '%').change();
        data.context.find('.sr-only').text(progress + '% Complete').change();
        if (progress === 100) {
          data.context.removeClass("working");
          data.context.find(".progress").replaceWith('<div class = "complete"></div>');
        }
      },
      success: function(e, data) {
        var id;
        id = e.id.$oid;
        $('.complete').replaceWith('<a class="remove-attachment btn-icon cancel-icon" data-method="delete" data-remote="true" href="/admin/candidates/' + id + '/test_task/testfile" rel="nofollow"></a>');
        remove_attachment();
      },
      fail: function(e, data) {
        data.context.addClass("error");
      }
    });

    function formatFileSize(bytes) {
      if (typeof bytes !== "number") {
        return "";
      }
      if (bytes >= 1000000000) {
        return (bytes / 1000000000).toFixed(2) + " GB";
      }
      if (bytes >= 1000000) {
        return (bytes / 1000000).toFixed(2) + " MB";
      }
      (bytes / 1000).toFixed(2) + " KB";
    };

    $(document).on("drop dragover", function(e) {
      e.preventDefault();
    });
  };

  $(document).ready(function() {
    remove_attachment();
    $('.best_in_place').best_in_place();
    $(".best_in_place").bind("ajax:success", function() {
      this.innerHTML = this.innerHTML.replace(/\n/g, "<br />");
    });
    upload_test_files($("#upload"), $("#dropzone"), $("#fileupload"));
    upload_test_files($("#upload-result"), $("#dropzone-result"), $("#fileupload-result"));
  });
}).call(this);
