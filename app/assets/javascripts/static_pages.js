


// new_submit page result loading

$(document).ready(function(){

  // window.location.search contains all url content after '?' (params)
  var apiUrl = "/api/get_discussions" + window.location.search;
  var $topDiscussionsTable = $('#top-discussions-table tbody');
  var $allDiscussionsTable = $('#all-discussions-table tbody');

  // init loading spinners
  $topDiscussionsTable.spin('small');
  $allDiscussionsTable.spin('small');

  // displays subreddit name if result is from reddit
  var ifSubreddit = function(result) {
    if (result.site == 'Reddit') {
      return '/r/' + result.subreddit;
    }
    else {
      return '';
    }
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
    return tRow;
  };

  // boolean check if results were retrieved
  var hasNoResults = function(resultSet){
    if (resultSet == 'top') {
      return ($topDiscussionsTable[0].children.length < 1) ? true : false;
    }
    else if (resultSet == 'all') {
      return ($allDiscussionsTable[0].children.length < 1) ? true : false;
    }
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

//   // fetch top_results
//   $.get( apiUrl, function( data ) {
//     topResults = data.top_results.results;

//     $.each(topResults, function(k, result) {
//       var row = addRow(result);
//       $topDiscussionsTable.append(row);
//     });
//   }, "json");


// // fetch all_results
//   $.get( apiUrl, function( data ) {
//     allResults = data.all_results.results;

//     $.each(allResults, function(k, result) {
//       var row = addRow(result);
//       $allDiscussionsTable.append(row);
//       console.log(result.title);
//     });
//   }, "json");

  oboe(apiUrl)
    // for each result that comes in, add as row
    .node('!.top_results.results*', function( result ){
      var row = addRow(result);
      $topDiscussionsTable.append(row);
    })
    // on first datum, disable spinner
    .node('!.top_results', function(){
      $topDiscussionsTable.spin(false);
    })
    // once done, if empty, add 'no results' p element
    .done( function(allResults){
      if ( hasNoResults('top') ){
        $('#top-results').append(showNoResults('top'));
      }
  });

  oboe(apiUrl)
    // for each result that comes in, add as row
    .node('!.all_results.results*', function( result ){
      var row = addRow(result);
      $allDiscussionsTable.append(row);
    })
    // on first datum, disable spinner
    .node('!.all_results', function(){
      $allDiscussionsTable.spin(false);
    })
    // once done, if empty, add 'no results' p element
    .done( function(allResults){
      if ( hasNoResults('all') ){
        $('#all-results').append(showNoResults('all'));
      }
  });
});