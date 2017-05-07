module SequenceDiagram
  module MethodInvocation
    class Event
      attr_reader :invoker, :invokee, :method_name

      def initialize(invoker:, invokee:, method_name:)
        @invoker = invoker
        @invokee = invokee
        @method_name = method_name
      end

      def return?
        !call?
      end

      def paths
        [invoker, invokee].map(&:path)
      end
    end
  end
end
