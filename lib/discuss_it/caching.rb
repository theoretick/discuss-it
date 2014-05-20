
require_relative 'caching/redis'

module DiscussIt
  module Caching
    # To enable "foo" caching mechanism create a `Caching::Foo` module with a
    # single #fetch method as a drop-in replacement for DiscussItApi#new.
  end
end
