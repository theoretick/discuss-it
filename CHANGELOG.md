
## 0.5.1 (2013-09-06)

* slashdot_api date now pre-parsed, still a string

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
