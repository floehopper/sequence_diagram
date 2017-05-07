require 'sequence_diagram/method_invocation/actor'
require 'pathname'

module SequenceDiagram
  module MethodInvocation
    class WhitelistFilter
      def initialize(paths)
        @paths = paths.map { |p| Pathname.new(p).realpath }
      end

      def filter(events)
        Enumerator.new do |yielder|
          events.each do |event|
            if outside_application?(event.invoker)
              event.invoker = Actor::Library.new
            end
            if outside_application?(event.invokee)
              event.invokee = Actor::Library.new
            end
            yielder << event
          end
        end.to_a
      end

      def outside_application?(actor)
        !@paths.include?(Pathname.new(actor.path).realpath)
      end
    end
  end
end
