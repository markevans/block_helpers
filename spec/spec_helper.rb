require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'block_helpers'

Spec::Runner.configure do |config|
end

# Taken from rspec-rails
# File lib/spec/rails/example/helper_example_group.rb, line 138
def eval_erb(text)
  ERB.new(text).result(binding)
end

def match_html(html)
  # Match two strings, but don't care about whitespace
  simple_matcher("should match #{html}"){|given| given.strip.gsub(/\s+/,' ').gsub('> <','><') == html.strip.gsub(/\s+/,' ').gsub('> <','><') }
end

