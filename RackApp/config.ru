require 'myproject/app'

app = Rack::Builder.new do
  run MyApp.new
end

run app
