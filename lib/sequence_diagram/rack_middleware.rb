require 'sequence_diagram/method_invocation/tracer'
require 'sequence_diagram/method_invocation/filter'
require 'sequence_diagram/js_sequence_diagram_formatter'

module SequenceDiagram
  class RackMiddleware
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

      tracer = MethodInvocation::Tracer.new
      tracer.trace do
        result = @app.call(env)
      end

      cleaner = Rails::BacktraceCleaner.new
      filter = MethodInvocation::Filter.new(cleaner)
      events = filter.filter(tracer.events)

      File.open(directory.join(filename), 'w') do |file|
        formatter = JsSequenceDiagramFormatter.new(file)
        formatter.write(events)
      end

      result
    end
  end
end
