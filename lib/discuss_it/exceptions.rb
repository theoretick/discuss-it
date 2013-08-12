module DiscussIt

  #----------------------------------------------------------------------
  # Exception class to catch invalid URL Errors
  #----------------------------------------------------------------------
  class UrlError < Exception; end


  #----------------------------------------------------------------------
  # FIXME: should this have a more general name?
  # Exception class to catch Timeouts and general HTTP Errors
  #----------------------------------------------------------------------
  class TimeoutError < Exception; end


  #----------------------------------------------------------------------
  # FIXME: should this have a more general name?
  # Exception class to catch Timeouts and general HTTP Errors
  #----------------------------------------------------------------------
  class UnknownError < Exception; end

end