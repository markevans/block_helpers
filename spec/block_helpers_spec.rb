require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module TestHelper
  extend BlockHelpers

  block_helper :test_helper do
    def hello
      'hello'
    end
  end


end

describe "BlockHelpers" do
  
  describe "block_helper" do
    
    before(:each) do
      include TestHelper
    end
    
    it "should make the named helper available" do
      TestHelper.instance_methods.include?('test_helper').should be_true
    end
    
    it "should work for a simple yielded object" do
      extend TestHelper
      raise eval_erb(%(
        <% test_helper do |h| %>
          <%= h.hello %>
        <% end %>
      ))
    end
  end
  
end
