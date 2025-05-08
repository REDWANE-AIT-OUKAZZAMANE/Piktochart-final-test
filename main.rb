#!/usr/bin/env ruby

# Load and run the web app
require_relative 'web_app'

# Configure for deployment
set_port = ENV['PORT'] || 8080
set_bind = ENV['HOST'] || '0.0.0.0'

AcmeWidgetWebApp.run!(host: set_bind, port: set_port) 