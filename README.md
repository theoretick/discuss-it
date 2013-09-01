# Discuss-it
#### Online link discussion tracker

## Version 0.4.8

[![Code Climate](https://codeclimate.com/github/theoretick/discuss-it.png)](https://codeclimate.com/github/theoretick/discuss-it)

Website for locating online discussions about a given article on Reddit, Hacker News, and Slashdot.

Currently hosted at: [discuss-it.herokuapp.com](https://discuss-it.herokuapp.com/)

## Features

Version 0.4.0 of Discuss-it takes a URL you think may have interesting
discussion somewhere on the internet and queries across a number of link
aggregators with comment systems.

After submitting your URL we return a page with links. The links we return take you directly to the comments page of the article in question so that you can begin talking about the link you searched for immediately.

Current list of queried sites:
* __Hacker News__
* __Reddit__
* __Slashdot__

The returned search results include the top search result as sorted by
upvotes/points for each queried site followed by a list of all returned
results below it ordered by the same criteria.

The API call is source agnostic and converts results from each site
into similar listing objects that can be manipulated and sorted easily.

Slashdot does not have an API so results from Slashdot are aggregated
by our own API which scrapes the most recent postings and stores them
as listing objects in a database.

## API

Want to use our app for easy searching?

Discuss It results can be conveniently accessed with a JSON request to our submit
page:
```
http://discussitapp.com/submit.json?url=http://merbist.com/2011/02/22/concurrency-in-ruby-explained/
```

## Bookmarklet

For easy searching, add Discuss-It search to your bookmark bar, just
add a new bookmark and paste in this hunk of JS:

```javascript
javascript:(function() {
  function searchDiscussIt() {
    var url = window.location.href;
    var discussit = 'http://discuss-it.herokuapp.com/submit?url=';
    window.location.href = discussit+url;
}
searchDiscussIt();
})();
```

## Documentation

* [changelog](http://github.com/theoretick/discuss-it/blob/master/CHANGELOG.md)
* [wiki](http://github.com/theoretick/discuss-it/wiki)

## Created and maintained by

**theoretick** :: [github](https://github.com/theoretick), [twitter](https://twitter.com/theoretick)

**ericalthatcher** :: [github](https://github.com/ericalthatcher), [twitter](https://twitter.com/ericalthatcher)

**CodingAntecedent** :: [github](https://github.com/CodingAntecedent), [twitter](https://twitter.com/JohannBenedikt)


_Find a bug? Contributions welcome._

## License

See [LICENSE](http://github.com/theoretick/discuss-it/blob/master/LICENSE) for the full license text.
