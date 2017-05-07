module SequenceDiagram
  class JsSequenceDiagramFormatter
    class Decorator
      class << self
        attr_accessor :classes_vs_instances
      end

      def initialize(object)
        @object = object
      end

      def to_s
        if @object.is_a?(Class)
          # @object.to_s.gsub('::', '~')
          @object.to_s
        else
          # address = @object.__id__ * 2
          # address += 0x100000000 if address < 0
          # "#{@object.class.to_s.gsub('::', '~')}(0x#{'%x' % address})"
          self.class.classes_vs_instances[@object.class] << @object
          instance_number = self.class.classes_vs_instances[@object.class].to_a.index(@object) + 1
          "#{@object.class.to_s}(#{instance_number})"
        end
      end
    end

    def initialize(io)
      @io = io
      Decorator.classes_vs_instances = Hash.new { |h, k| h[k] = Set.new }
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
