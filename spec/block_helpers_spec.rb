require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Taken partly from rspec-rails
# File lib/spec/rails/example/helper_example_group.rb, line 138
def eval_erb(text)
  ERB.new(text).result(@helper.get_binding)
end

describe 'block helpers' do

  before(:each) do
    module TestHelper

      class TestHelperMethod < BlockHelpers::BlockHelper
        def hello
          'Hi there'
        end
      end

    end
    class TestClass
      include TestHelper
      def get_binding
        binding
      end
    end
    @helper = TestClass.new
  end
  
  describe "block_helper" do
    
    it "should make the named helper available" do
      @helper.should respond_to(:test_helper_method)
    end
    
    it "should work for a simple yielded object" do
      eval_erb(%(
        <% test_helper_method do |h| %>
          <%= h.hello %>
        <% end %>
      )).should match_html("Hi there")
    end
  end
  
end
