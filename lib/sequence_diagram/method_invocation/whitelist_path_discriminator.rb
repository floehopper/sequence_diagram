module SequenceDiagram
  module MethodInvocation
    class WhitelistPathDiscriminator
      def initialize(paths)
        @paths = paths.map { |p| Pathname.new(p).realpath }
      end

      def inside_application?(actor)
        @paths.include?(Pathname.new(actor.path).realpath)
      end
    end
  end
end
