module Filelock
  class ExecTimeout < Timeout::Error
      def message
        "Didn't finish executing Filelock block within the timeout specified."
      end
  end
end
