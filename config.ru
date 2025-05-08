require './web_app'

# Set the environment
ENV['RACK_ENV'] = ENV['RACK_ENV'] || 'production'

# Run the application
run AcmeWidgetWebApp 