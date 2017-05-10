require 'sequence_diagram/method_invocation/event'

module SequenceDiagram
  module MethodInvocation
    class ReturnEvent < Event
      alias_method :source, :invokee
      alias_method :target, :invoker

      alias_method :source=, :invokee=
      alias_method :target=, :invoker=

      def call?
        false
      end

      def exiting_application?(path_discriminator)
        path_discriminator.inside_application?(invokee) && !path_discriminator.inside_application?(invoker)
      end

      def entering_application?(path_discriminator)
        !path_discriminator.inside_application?(invokee) && path_discriminator.inside_application?(invoker)
      end
    end
  end
end
