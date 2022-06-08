(function() {
  function ready_search() {
    ajax_filters();
  };

  function check_search_field() {
    if ($('#search_query, #search_query_candidate').val() === "") {
      $('input[value="Search in"]').attr('disabled', true);
    } else {
      $('input[value="Search in"]').attr('disabled', false);
    }
  };

  function ajax_filters() {
    candidate_ajax_filters();
  };

  function candidate_ajax_filters() {
    $('.candidate-search-partial input, .candidate-search-partial select, .candidate-search-partial .date, .ui-autocomplete').on("change hide keyup paste propertychange click", function() {
      var filters = gather_candidate_filters();
      console.log(filters);
      $.ajax({
        url: "/admin/candidates/search",
        type: "GET",
        data: filters
      });
    });
  };

  function gather_candidate_filters() {
    var data = {};
    $('.panel-body input:checked').each(function() {
      var key = $(this).attr('name');
      data[key] = '1';
    });
    data['search_query'] = $('#search_query_candidate').val();
    data['per_page'] = $('#per_page').val();
    data['search_in'] = $('#search_in').val();
    var from = $('.panel-body input#date-range_frome').val();
    var to = $('.panel-body input#date-range_to').val();
    if (from !== "" && to !== "") {
      data['date[from]'] = from;
      data['date[to]'] = to;
    }
    return data;
  };

  function select_searching_text() {
    var queries = $('#search_query, #search_query_candidate').val();
    if (queries) {
      queries.split(' ').forEach(function(query) {
        $('td.name,td.reference,td.techs,td.contacts #name').highlight(query);
      });
    }
  };

  $(document).ready(ready_search);

  $(document).on('page:load', ready_search);
}).call(this);