require 'sequence_diagram/method_invocation/actor'

module SequenceDiagram
  class JsSequenceDiagramFormatter
    class InstanceRegistry
      def initialize
        @classes_vs_instances = Hash.new { |h, k| h[k] = Set.new }
      end

      def register(instance)
        @classes_vs_instances[instance.class] << instance
      end

      def number_for(instance)
        @classes_vs_instances[instance.class].to_a.index(instance) + 1
      end
    end

    class Decorator
      class << self
        attr_accessor :instance_registry
      end

      def initialize(actor)
        @actor = actor
      end

      def object
        @actor.object
      end

      def to_s
        if object.is_a?(Class)
          format_class(object)
        else
          self.class.instance_registry.register(object)
          instance_number = self.class.instance_registry.number_for(object)
          "#{format_class(object.class)}(#{instance_number})"
        end
      end

      def format_class(klass)
        klass.to_s.sub('SequenceDiagram::MethodInvocation::Actor::Library', 'Library').gsub('::', '~').sub(%r{#<Class\:0x\w+>}, 'AnonymouseClass')
      end
    end

    def initialize(io)
      @io = io
      Decorator.instance_registry = InstanceRegistry.new
    end

    def write(events)
      events.each do |event|
        if event.call?
          from = Decorator.new(event.invoker)
          to = Decorator.new(event.invokee)
          @io.puts "#{from}->#{to}: #{event.method_name}"
        else
          from = Decorator.new(event.invokee)
          to = Decorator.new(event.invoker)
          unless event.invokee.object == event.invoker.object
            @io.puts "#{from}-->#{to}: #{event.method_name}"
          end
        end
      end
    end
  end
end
