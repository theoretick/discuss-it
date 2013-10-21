// on document ready checks if Reddit, HN, or Slashdot APIs are down,
// if so, display warning.


// sets the banner text if api is offline
var setStatus = function(siteName, status) {
  apiIndicator = document.getElementById( siteName + '-api-status');
  if (status) {
    // If site is up, currently display nothing
  } else {
    apiIndicator.innerHTML = siteName + 'API is DOWN';
    apiIndicator.style.color = 'red';
  }
};

var imageLoad = function(siteName, siteUrl){
  var img = document.createElement('img');
    img.src = siteUrl;
    img.onload = function(){
      setStatus(siteName, true);
    };
    img.onerror = function(){
      setStatus(siteName, false);
    };
    img.style.display = 'none';
    document.body.appendChild(img);
};


var checkReddit = function(){
  imageLoad('reddit','//www.reddit.com/favicon.ico');
};

var checkHn = function(){
  imageLoad('hackernews','//api.thriftdb.com/favicon.ico');
};

var checkSlashdot = function(){
  imageLoad('slashdot','//slashdot-api.herokuapp.com/favicon.ico');
};

// on doc ready checks all apis
// (function() {
//   checkReddit();
//   checkHn();
//   checkSlashdot();
// })();
