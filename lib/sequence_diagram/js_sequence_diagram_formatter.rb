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

      def initialize(object)
        @object = object
      end

      def to_s
        if @object.is_a?(Class)
          @object.to_s.gsub('::', '~')
        else
          self.class.instance_registry.register(@object)
          instance_number = self.class.instance_registry.number_for(@object)
          "#{@object.class.to_s.gsub('::', '~')}(#{instance_number})"
        end
      end
    end

    def initialize(io)
      @io = io
      Decorator.instance_registry = InstanceRegistry.new
    end

    def write(events)
      events.each do |event|
        if event.call?
          from = Decorator.new(event.invoker.object)
          to = Decorator.new(event.invokee.object)
          @io.puts "#{from}->#{to}: #{event.method_name}"
        else
          from = Decorator.new(event.invokee.object)
          to = Decorator.new(event.invoker.object)
          unless event.invokee.object == event.invoker.object
            @io.puts "#{from}-->#{to}: #{event.method_name}"
          end
        end
      end
    end
  end
end
