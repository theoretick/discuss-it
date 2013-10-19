
$(document).ready(function(){
  // window.location.search contains all url content after '?' (params)
  oboe('/oboe_submit.json' + window.location.search)
    .node('top_results.results*', function( topResult ){
    // .node('{ results }', function( topResult ){

          // %tr
          //   %td
          //     = listing.site
          //     - if listing.site == 'Reddit'
          //       %p
          //         = "/r/#{listing.subreddit}"
          //     .ratings
          //       %br
          //       %p.rating-score-box{title:"Score"}
          //         - if listing.site == "Slashdot"
          //           = '-'
          //         - else
          //           = listing.score
          //       %p.rating-comment-box{title:"Comment Count"}
          //         = listing.comment_count
          //   %td.url-friendly
          //     =  link_to listing.title, listing.location

        var row = document.createElement('tr');
        var $data = $('<td>' + topResult.site + '</td><td>' +
          '<a href="' + topResult.permalink + '">' + topResult.title + '</a>' + '</td>' +
          '<td>' + topResult.score + '</td>');

        $('#top-discussions-table tbody').append(row);
        $(row).append($data);

      console.log( 'count of tops is' + topResult );
    })
    .done( function(allThings){
      console.log( 'there are ' + allThings.children.length + ' that are top ' +
                   'and ' + allThings.all_results.length + ' that aren\'t.' );
    });
});