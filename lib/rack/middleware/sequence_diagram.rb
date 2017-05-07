require "method_invocation_tracer"
require "method_invocation_filter"

module Rack
  module Middleware
    class Foo
      class Decorator
        def initialize(object)
          @object = object
        end

        def to_s
          if @object.is_a?(Class)
            @object.to_s.gsub('::', '~')
          else
            address = @object.__id__ * 2
            address += 0x100000000 if address < 0
            "#{@object.class.to_s.gsub('::', '~')}(0x#{'%x' % address})"
          end
        end
      end

      def initialize(app)
        @app = app
        @root = Rails.root.join(File.join(%w(tmp traces)))
        FileUtils.mkdir_p(@root)
      end

      def call(env)
        request = ActionDispatch::Request.new(env)
        result = nil

        directory = @root.join(request.path.sub(%r{^/}, ''))
        timestamp = Time.now.strftime('%Y%m%d%H%M%S%6N')
        filename = [timestamp, 'txt'].join('.')
        FileUtils.mkdir_p(directory)

        File.open(directory.join(filename), 'w') do |file|
          tracer = MethodInvocationTracer.new
          events = tracer.trace do
            result = @app.call(env)
          end
          filter = MethodInvocationFilter.new
          filter.filter(events).each do |event|
            case event
            when MethodInvocationTracer::CallEvent
              from = Decorator.new(event.invoker.object)
              to = Decorator.new(event.invokee.object)
              file.puts "#{from}->#{to}: #{event.method_name}"
            when MethodInvocationTracer::ReturnEvent
              from = Decorator.new(event.invokee.object)
              to = Decorator.new(event.invoker.object)
              file.puts "#{from}-->#{to}: #{event.method_name}"
            end
          end
        end
        result
      end
    end
  end
end
