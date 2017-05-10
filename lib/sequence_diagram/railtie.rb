require 'rails/railtie'
require 'sequence_diagram/rack_middleware'
require 'sequence_diagram/rspec_around'

module SequenceDiagram
  class Railtie < Rails::Railtie
    initializer 'sequence_diagram.add_middleware' do |app|
      app.middleware.use SequenceDiagram::RackMiddleware
    end

    initializer 'sequence_diagram.add_rspec_around_block' do
      RSpec.configure do |c|
        c.around(:each, &RSpecAround.method(:block))
      end
    end
  end
end
