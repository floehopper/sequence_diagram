require 'sequence_diagram/method_invocation/event'

module SequenceDiagram
  module MethodInvocation
    class ReturnEvent < Event
      def call?
        false
      end
    end
  end
end
