require 'sequence_diagram/method_invocation/event'

module SequenceDiagram
  module MethodInvocation
    class CallEvent < Event
      def call?
        true
      end
    end
  end
end
