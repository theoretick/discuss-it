module DiscussIt

  #----------------------------------------------------------------------
  # Exception class to catch invalid URL Errors
  #----------------------------------------------------------------------
  class UrlError < StandardError; end

  #----------------------------------------------------------------------
  # Exception class to catch Timeouts and general HTTP Errors
  #----------------------------------------------------------------------
  class TimeoutError < StandardError; end

  #----------------------------------------------------------------------
  # Exception class to catch Sources unreachable and downtime
  #----------------------------------------------------------------------
  class SourceDownError < StandardError; end

end