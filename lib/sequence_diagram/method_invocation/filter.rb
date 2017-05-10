require 'sequence_diagram/method_invocation/actor'
require 'pathname'

module SequenceDiagram
  module MethodInvocation
    class Filter
      def initialize(path_discriminator)
        @path_discriminator = path_discriminator
      end

      def filter(events)
        current_library_object = [Actor.new(object: Actor::Library.new, path: '')]
        library_objects = []
        Enumerator.new do |yielder|
          events.each do |event|
            if event.inside_application?(@path_discriminator)
              if event.exiting_application?(@path_discriminator)
                if event.call?
                  actor = Actor.new(object: Actor::Library.new, path: '')
                else
                  actor = library_objects.pop
                end
                event.target = actor
                current_library_object.push(actor)
              end
              if event.entering_application?(@path_discriminator)
                actor = current_library_object.pop
                event.source = actor
                if event.call?
                  library_objects.push(actor)
                end
              end
              yielder << event
            end
          end
        end.to_a
      end
    end
  end
end
