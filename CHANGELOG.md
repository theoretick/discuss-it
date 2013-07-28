## 3.5.2 (2013-07-28)

* Updated README with word-choice changes, twitter and github links, and bookmarklet [theoretick]
* More robust slashdot fetching, cleaner code, now idempotent, less hackery
* colorized rake tasks! whooo doggy!

## 3.5 (2013-07-27)

* Preliminary support for slashdot links
  - DiscussIt app queries concurrent webrick instance for serving slashdot DB postings
  - slashdot scrapper populates DB with raketask
  - currently returns any slashdot discussion if found in DB
  - slashdot_postings has_many urls
* cleaner discuss_it_api code
* better comments appwide
* added CHANGELOG

## 3.3.1 (2013-07-26)

* updated README [CodingAntecedent]

## 3.3 (2013-07-25)

* now suggested searches on homepage [CodingAntecedent]

## 3.0 ()

* APIv3 -- YA rewrite better, even more OOPy [theoretick]
* Prettier pages sitewide, now w/ FlatUI
* full unittest suite for APIv3

## 2.0 ()

* APIv2 -- much much better, more OOPy
* full unittest suite for APIv2 [CodingAntecedent]

## 1.0 ()

* support HN searches
* support Reddit searches
* all queries live