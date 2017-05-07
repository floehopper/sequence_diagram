require 'sequence_diagram/method_invocation/actor'
require 'sequence_diagram/method_invocation/call_event'
require 'sequence_diagram/method_invocation/return_event'

module SequenceDiagram
  module MethodInvocation
    class Tracer
      attr_reader :events

      def initialize
        @events = []
      end

      def trace(&block)
        root = Actor.new(object: self, path: __FILE__)
        stack = [root]
        TracePoint.new(:call, :return) do |tp|
          case tp.event
          when :call
            event = CallEvent.new(
              invoker: stack.last,
              invokee: Actor.new(object: tp.self, path: tp.path),
              method_name: tp.method_id
            )
            stack.push(Actor.new(object: tp.self, path: tp.path))
          when :return
            stack.pop
            event = ReturnEvent.new(
              invoker: stack.last,
              invokee: Actor.new(object: tp.self, path: tp.path),
              method_name: tp.method_id
            )
          end
          @events << event
        end.enable do
          block.call
        end
      end
    end
  end
end
