require 'rails/railtie'
require 'sequence_diagram/rack_middleware'

module SequenceDiagram
  class Railtie < Rails::Railtie
    initializer 'sequence_diagram.add_middleware' do |app|
      app.middleware.use SequenceDiagram::RackMiddleware
    end
  end
end
