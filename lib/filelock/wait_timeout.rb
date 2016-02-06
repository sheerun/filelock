module Filelock
  class WaitTimeout < Timeout::Error
      def message
        "Unable to acquire a file lock within the wait timeout specified."
      end
  end
end
