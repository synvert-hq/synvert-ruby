module Synvert
  # Rewriter not found exception.
  class RewriterNotFound < Exception
  end

  # Gemfile.lock not found exception.
  class GemfileLockNotFound < Exception
  end

  # Method not supported exception.
  class MethodNotSupported < Exception
  end
end
