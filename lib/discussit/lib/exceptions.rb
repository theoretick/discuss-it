module DiscussIt

  #----------------------------------------------------------------------
  # Exception class to catch invalid URL Errors
  #----------------------------------------------------------------------
  class DiscussItUrlError < Exception; end


  #----------------------------------------------------------------------
  # FIXME: should this have a more general name?
  # Exception class to catch Timeouts and general HTTP Errors
  #----------------------------------------------------------------------
  class DiscussItTimeoutError < Exception; end


  #----------------------------------------------------------------------
  # FIXME: should this have a more general name?
  # Exception class to catch Timeouts and general HTTP Errors
  #----------------------------------------------------------------------
  class DiscussItUnknownError < Exception; end

end