#
# magic
#----------------------------------------------------------------------
#
# does api call to slashdot
# gets XML back
# parses relevant xml
# builds (model) Listing object
#
# runs daily-ish

#----------------------------------------------------------------------

require 'httparty'
require 'nokogiri'

# json_from_localhost_slashdot_api = {
#      "hits" => 2,
#   "results" => [
#        {
#          "title" => "13-Inch Haswell-Powered MacBook Air With PCIe SSD Tested"
#       "postdate" => 2012-12-02
#      "permalink" => "http://apple.slashdot.org/story/13/07/24/2055208/13-inch-haswell-powered-macbook-air-with-pcie-ssd-tested"
#   "commentcount" => 182,
#            "url" => "http://hothardware.com/Reviews/Apples-HaswellPowered-13Inch-MacBook-Air/",
#        },
#        {
#          "title" => "13-Inch Haswell-Powered MacBook Air With PCIe SSD Tested"
#       "postdate" => 2013-09-29
#      "permalink" => "http://apple.slashdot.org/story/13/07/24/2055208/13-inch-haswell-powered-macbook-air-with-pcie-ssd-tested"
#   "commentcount" => 12,
#            "url" => "http://hothardware.com/Reviews/Apples-HaswellPowered-13Inch-MacBook-Air/?page=4",
#        }
#   ]
# }
#