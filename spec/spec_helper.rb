require 'rubygems'
gem 'activesupport'
gem 'actionpack'
require File.dirname(__FILE__)+'/../lib/block_helpers'

# Hacks to get spec/rails to work
require 'action_controller'
$:.unshift File.dirname(__FILE__)+'/for_spec_rails'
RAILS_ENV = 'test'

require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
end

def match_html(html)
  # Match two strings, but don't care about whitespace
  simple_matcher("should match #{html}"){|given| given.strip.gsub(/\s+/,' ').gsub('> <','><') == html.strip.gsub(/\s+/,' ').gsub('> <','><') }
end

