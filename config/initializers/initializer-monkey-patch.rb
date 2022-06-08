module Mongoid
  module Document
    def cache_version
      if respond_to?(:updated_at)
        updated_at.utc.to_s(:usec)
      else
        nil
      end
    end
  end
end
