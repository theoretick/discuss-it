# Discuss-it 
#### Online article discussion tracker

## Version 3.5

[![Code Climate](https://codeclimate.com/github/theoretick/discuss-it.png)](https://codeclimate.com/github/theoretick/discuss-it)

Website for locating online discussions about a given article on Reddit, Hacker News, and Slashdot.

Currently hosted at: [discuss-it.herokuapp.com](https://discuss-it.herokuapp.com/)

## Features

Version 3.5 of Discuss-it takes a URL of an interesting site which you think may have interesting discussion somewhere on the internet and queries the search functions of link aggregators with comment systems.

After submitting your URL we return a page with links. The links we return take you directly to the comments page of the article in question so that you can begin talking about the link you searched for immediately.

Current list of queried sites:
* __Hacker News__
* __Reddit__
* __Slashdot__

The returned search results include the top search result as sorted by upvotes/points for each queried site followed by a list of all returned results below it ordered by the same criteria.

The API call is source agnostic and converts results from each site into similar listing ojbects that can be manipulated and sorted easily.

Slashdot does not have an API so results from Slashdot are aggregated by our own API which scrapes the most recent postings and stores them as listing objects in a database.


## Contributors

Created by: [Theoretick](https://github.com/Theoretick) - [ericalthatcher](https://github.com/ericalthatcher) - [CodingAntecedent](https://github.com/CodingAntecedent)
