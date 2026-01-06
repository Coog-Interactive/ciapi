require 'sinatra'
require 'stripe'

require_relative 'routes/payment'

get '/' do
  "<h1>Hello world!</h1>"
end