## 0.8.3

## 0.8.2

## 0.8.1 (2016-01-02)

 * Render pages with react/redux
 * Swap deploys from exrm/edeliver to distillery
 * convert layouts from haml to eex
 * Remove dead developers portal

## 0.8.0 (2016-03-08)

 * complete rewrite in Elixir/Phoenix

## 0.7.4 (2015-08-30)

 * Add capistrano and puma for production deploys

## 0.7.3 (2015-01-08)

 * Updated HN URL to fix 301 and perform precise URL match
 * Minor refactoring

## 0.7.2 (2014-05-18)

 * Added subreddit loader, no integration

## 0.7.1 (2014-05-18)

 * Much more/better logging. Log file, per request, cleaner msgs
 * Better caching organization
 * Re-added ENV-specific caching

## 0.7.0 (2014-05-10)

 * Now a sinatra app!  simpler and junk
 * Has caching through redis
 * Allow selection of sources to search

## 0.6.0 (2014-04-14)

 * Updated HNSearch to new Algolia host and path
 * Much improved error handling (it exists now and isn't a massive pile of rescues)
 * More Error conditions and reporting of downed sources
 * Cleaned up some minor method calls
 * DiscussItApp class now takes optional source argument for queries to a single site
 * Updated docs

## 0.5.8 (2013-12-08)

 * fixed submit-page issue with displaying ranking as 'undefined'
 * added error message display to submit-page for DI internal server error
 * updated specs with let syntax and clearer messages

## 0.5.7 (???)

 * added response caching per API-call along with full listing fetch
 * changed response caching to full-listing for DEV environment only,
   else cache per call

## 0.5.6 (2013-11-17)

 * moved trailing-slash stripper into controller for now so works for ajax & caching
 * replaced old-submit with AJAX-ified newsubmit
 * removed excess comments

## 0.5.5 (2013-10-20)

 * added newsubmit page with initial rewrite for AJAX-loading of results
 * now filters zero-comment threads for BOTH top and all results on
   submit page

## 0.5.4 (2013-10-20)

 * added filtering of zero-comment threads to submit page

## 0.5.3 (2013-10-10)

 * added rails_admin panel

## 0.5.2 (2013-10-06)

 * added tooltip to explain score + comment_count on submit page

## 0.5.1 (2013-09-06)

* removed slashdot_api references from discuss-it codebase. Now
  fully-separate app (github.com/theoretick/slashdot-api)
* added Faraday::Timeout rescue
* better versioning. see lib/discuss-it/version
* added version number to user-agent

## 0.5.0 (2013-09-02)

* added developer portal at ```http://discussitapp.com/api```
* added user accounts!
* added persistent searches (linked to user if signed in)
* displays comment_count and score on submit page now
* JSON return on submit page now has better sectioning w/ hit_count on each
* many minor bugfixes
* many minor code cleaning tweaks

## 0.4.9 (2013-08-18)

* changed DiscussIt API calls to Faraday+Typhoes, in prep for parallelism

## 0.4.8 (2013-08-18)

* add comment_count to all API returns for smarter sorting
* top/all results renamed to top/all discussions
* top discussions now sort as well, highest is first

## 0.4.6 (2013-08-18)

* changed 'query' param to 'url' for consistency

## 0.4.5 (2013-08-16)

* added user accounts with devise
* added search model, currently unconnected to anything


## 0.4.3 (2013-08-16)

* better routes, removed static_pages namespace
* migrated DB to postgres
* added api_status.JS indicator to landing. displays if any external APIS are down

## 0.4.1 (2013-08-14)

* spec refactoring
* better DiscussItAPI version handling, default to latest
* minor css tweaks

## 0.4.0 (2013-08-11)

* discuss_it is now a module, subdivided and elegantly clean
* changed background image to pure-css with linear-gradient

## 0.3.6 (2013-08-03)

* added more tests for discuss_it. Now full coverage for app-side.

## 0.3.6 (2013-08-01)

* added many rescues for HTTP timeouts and nil responses, far more robust
* cleaned up and updated comments

## 0.3.5 (2013-07-30)

* deleted extra scaffolding files and coffee-script crap [theoretick]
* added nokogiri to gemfile, whoops
* better comments
* moved inline style into SCSS
* added favicon
* now deployed on dual heroku instances which query themselves. crazzyy

## 0.3.5 (2013-07-28)

* Updated README with word-choice changes, twitter and github links, and bookmarklet [theoretick]
* More robust slashdot fetching, cleaner code, now idempotent, less hackery
* colorized rake tasks! whooo doggy!

## 0.3.5 (2013-07-27)

* Preliminary support for slashdot links
  - DiscussIt app queries concurrent webrick instance for serving slashdot DB postings
  - slashdot scrapper populates DB with raketask
  - currently returns any slashdot discussion if found in DB
  - slashdot_postings has_many urls
* cleaner discuss_it_api code
* better comments appwide
* added CHANGELOG

## 0.3.3 (2013-07-26)

* updated README [CodingAntecedent]

## 0.3.2 (2013-07-25)

* now suggested searches on homepage [CodingAntecedent]

## 0.3.0 ()

* APIv3 -- YA rewrite better, even more OOPy [theoretick]
* Prettier pages sitewide, now w/ FlatUI
* full unittest suite for APIv3

## 0.2.0 ()

* APIv2 -- much much better, more OOPy
* full unittest suite for APIv2 [CodingAntecedent]

## 0.1.0 ()

* support HN searches
* support Reddit searches
* all queries live
