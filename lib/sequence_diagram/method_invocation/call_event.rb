require 'sequence_diagram/method_invocation/event'

module SequenceDiagram
  module MethodInvocation
    class CallEvent < Event
      alias_method :source=, :invoker=
      alias_method :target=, :invokee=

      def call?
        true
      end

      def exiting_application?(path_discriminator)
        path_discriminator.inside_application?(invoker) && !path_discriminator.inside_application?(invokee)
      end

      def entering_application?(path_discriminator)
        !path_discriminator.inside_application?(invoker) && path_discriminator.inside_application?(invokee)
      end
    end
  end
end
