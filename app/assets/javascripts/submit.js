////////////////////////////////////////////////////////////////////
// static_pages#submit JS for AJAX result loading
////////////////////////////////////////////////////////////////////
$(document).ready(function(){

  // window.location.search contains all url content after '?' (params)
  var apiUrl = "/api/get_discussions" + window.location.search;
  var $topDiscussionsTable = $('#top-discussions-table tbody');
  var $allDiscussionsTable = $('#all-discussions-table tbody');
  var $filteredDiscussionsTable = $('#filtered-discussions-table tbody');

  // init loading spinners
  $topDiscussionsTable.spin('small');
  $allDiscussionsTable.spin('small');

  // hide filtered results unless they exist
  $('#filtered-btn').hide();
  $('#filtered-results').hide();

  // displays subreddit name if result is from reddit
  var ifSubreddit = function(result) {
    return result.site == 'Reddit' ? '/r/' + result.subreddit : '';
  };

  // builds table row for given result
  var addRow = function(result) {
    tRow = document.createElement('tr');
    tCell = tRow.insertCell(0);
    tCell.innerHTML = result.site + '<br/>' + ifSubreddit(result);
    tCell = tRow.insertCell(1);
    tCell.innerHTML = '<a href="' + result.location + '">' + result.title + '</a>';
    tCell = tRow.insertCell(2);
    tCell.innerHTML = result.ranking;
    tCell.style.textAlign = "right";
    return tRow;
  };

  // displays 'no results found' p element
  var showNoResults = function(resultSet){
    var $noResultP = $(document.createElement('p'));
    $noResultP.addClass('text-center');
    if (resultSet == 'top'){
      $noResultP.html('Sorry, no discussions found. <a href="/">Try Again?</a>');
    }
    else if (resultSet == 'all'){
      $noResultP.html('No additional results found.');
    }
    return $noResultP;
  };

  var showServerError = function(){
    var $serverErrorP = $(document.createElement('p'));
    $serverErrorP.addClass('text-center');
    $serverErrorP.html('INTERNAL SERVER ERROR');
    return $serverErrorP;
  };


  ////////////////////////////////////////////////////////////////////
  // AJAX
  ////////////////////////////////////////////////////////////////////

  oboe(apiUrl)
    // on first datum, disable spinner
    .node('!.top_results', function(){
      $topDiscussionsTable.spin(false);
    })
    .node('!.all_results', function(){
      $allDiscussionsTable.spin(false);
    })

    // for each result that comes in, add as row
    .node('!.top_results.results*', function( result ){
      var row = addRow(result);
      $topDiscussionsTable.append(row);
    })
    .node('!.all_results.results*', function( result ){
      var row = addRow(result);
      $allDiscussionsTable.append(row);
    })

    // display if has filtered results
    .node('!.filtered_results.results*', function( result ){
      if (result) {
        $('#filtered-btn').show();
        $('#filtered-results').show();
      }
      var row = addRow(result);
      $filteredDiscussionsTable.append(row);
    })

    // once done, if empty, add 'no results' p elements
    .done(function(allResults) {
      if (allResults.errors.length > 0) {
        for (var error in allResults.errors) {
          console.log(error);
        }
      }
      if (allResults.total_hits === 0) {
        $('#top-results').append(showNoResults('top'));
        $('#all-results').append(showNoResults('all'));
      }
    })
    .fail(function() {
      $topDiscussionsTable.spin(false);
      $allDiscussionsTable.spin(false);
      // $('#top-results').append(showServerError());
      // $('#all-results').append(showServerError());
    });

});
