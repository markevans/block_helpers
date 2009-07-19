# Hacks to get spec/rails to work

class ApplicationController < ActionController::Base
end

module Rails
  module VERSION
    STRING = '2.3.0'
  end
end
