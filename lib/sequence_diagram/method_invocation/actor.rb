module SequenceDiagram
  module MethodInvocation
    class Actor
      class Library; end

      attr_reader :object, :path

      def initialize(object:, path:)
        @object = object
        @path = path
      end
    end
  end
end
