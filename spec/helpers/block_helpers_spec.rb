require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module TestHelperModule
end

describe TestHelperModule do

  describe "simple block_helper" do
    
    before(:each) do
      class TestHelperModule::TestHelper < BlockHelpers::BlockHelper
        def hello
          'Hi there'
        end
      end
    end
    
    it "should make the named helper available" do
      helper.should respond_to(:test_helper)
    end
    
    it "should work for a simple yielded object" do
      eval_erb(%(
        <% test_helper do |h| %>
          <p>Before</p>
          <%= h.hello %>
          <p>After</p>
        <% end %>
      )).should match_html("<p>Before</p> Hi there <p>After</p>")
    end
    
  end
    
  describe "surrounding the block" do

    before(:each) do
      class TestHelperModule::TestHelperSurround < BlockHelpers::BlockHelper
        def render(body)
          %(
            <p>Before</p>
            #{body}
            <p>After</p>
          )
        end
      end
    end

    it "should surround a simple block" do
      eval_erb(%(
        <% test_helper_surround do %>
          Body here!!!
        <% end %>
      )).should match_html("<p>Before</p> Body here!!! <p>After</p>")
    end
  end
  
end
