require 'pathname'

module SequenceDiagram
  module MethodInvocation
    class WhitelistFilter
      def initialize(paths)
        @paths = paths.map { |p| Pathname.new(p).realpath }
      end

      def filter(events)
        events.select { |e| whitelisted?(e) }
      end

      def whitelisted?(event)
        event.paths.all? { |p| @paths.include?(Pathname.new(p).realpath) }
      end
    end
  end
end
