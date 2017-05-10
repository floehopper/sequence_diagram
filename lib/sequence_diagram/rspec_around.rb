require 'sequence_diagram/method_invocation/tracer'
require 'sequence_diagram/method_invocation/filter'
require 'sequence_diagram/js_sequence_diagram_formatter'
require 'rails/backtrace_cleaner'

module SequenceDiagram
  class PathDiscriminator
    def initialize
      @cleaner = Rails::BacktraceCleaner.new
    end

    def inside_application?(actor)
      @cleaner.clean([actor.path]).any?
    end
  end

  class RSpecAround
    def self.block(example)
      root = Rails.root.join(File.join(%w(tmp traces)))
      FileUtils.mkdir_p(root)

      directory = root.join(example.file_path)
      filename = [example.description.parameterize, 'txt'].join('.')
      FileUtils.mkdir_p(directory)

      tracer = SequenceDiagram::MethodInvocation::Tracer.new
      tracer.trace do
        example.run
      end

      discriminator = SequenceDiagram::PathDiscriminator.new
      filter = SequenceDiagram::MethodInvocation::Filter.new(discriminator)
      events = filter.filter(tracer.events)

      File.open(directory.join(filename), 'w') do |file|
        formatter = SequenceDiagram::JsSequenceDiagramFormatter.new(file)
        formatter.write(events)
      end
    end
  end
end
