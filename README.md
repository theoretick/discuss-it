# Discuss-it
#### Online link discussion tracker

## Version 0.7.1

[![Code Climate](https://codeclimate.com/github/theoretick/discuss-it.png)](https://codeclimate.com/github/theoretick/discuss-it)

Website for locating online discussions about a given article on Reddit, Hacker News, and Slashdot.

Currently hosted at: [www.discussitapp.com](http://www.discussitapp.com/)

## Features

Discuss-it takes a URL you think may have interesting
discussion online and queries across a number of discussion hubs.

After submitting your URL we return a page of discussions. The links
take you directly to the comments page of the article in question so that
you can begin talking about the url you searched for immediately.

Current list of queried sites:
* __Hacker News__
* __Reddit__
* __Slashdot__

The returned results include the top discussions as sorted by upvotes/points
for each queried site followed by all discussions found.

The API call is source agnostic and converts results from each site
into similar listing objects that can be manipulated and sorted easily.

Slashdot does not have an API so results from Slashdot are aggregated
by our custom API which scrapes the most recent postings and stores them
as listings in a database.

## Developer API

__See more info on our [Developer Portal](http://www.discussitapp.com/api)__

Want to use our app for easy searching?

Discuss It results can be conveniently accessed via our submit page:
```
http://www.discussitapp.com/submit.json?url=http://example.com/
```

## Bookmarklet

For easy searching, add Discuss-It search to your bookmark bar, just
add a new bookmark and paste in this hunk of JS:

```javascript
javascript:(function() {
  function searchDiscussIt() {
    var url = window.location.href;
    var discussit = 'http://www.discussitapp.com/submit?url=';
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

**CodingAntecedent** :: [github](https://github.com/CodingAntecedent), [twitter](https://twitter.com/JohannBenedikt)

**ericalthatcher** :: [github](https://github.com/ericalthatcher), [twitter](https://twitter.com/a_la_erica)


_Find a bug? Contributions welcome._

## License

See [LICENSE-APACHE](http://github.com/theoretick/discuss-it/blob/master/LICENSE-APACHE) for the full license text.
