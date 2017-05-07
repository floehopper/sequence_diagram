module SequenceDiagram
  module MethodInvocation
    class Filter
      def initialize(backtrace_cleaner)
        @cleaner = backtrace_cleaner
      end

      def filter(events)
        events.select { |e| inside_application?(e) }
      end

      def inside_application?(event)
        @cleaner.clean(event.paths).length == event.paths.length
      end
    end
  end
end
