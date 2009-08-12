require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module TestHelperModule
end

describe TestHelperModule do

  describe "simple block_helper" do
    
    before(:each) do
      class TestHelperModule::TestHelper < ActionView::BlockHelper
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
  
  describe "access to other methods via 'helper'" do
    before(:each) do
      module TestHelperModule
        def yoghurt; 'Yoghurt'; end
        class TestHelper
          def yog
            helper.yoghurt[0..2]
          end
          def jelly_in_div
            helper.content_tag :div, 'jelly'
          end
        end
      end
    end
    it "should give the yielded renderer access to other methods" do
      eval_erb(%(
        <% test_helper do |r| %>
          <%= r.yog %>
        <% end %>
      )).should match_html("Yog")
    end
    it "should give the yielded renderer access to normal actionview helper methods" do
      eval_erb(%(
        <% test_helper do |r| %>
          <%= r.jelly_in_div %>
        <% end %>
      )).should match_html("<div>jelly</div>")
    end
  end
  
  describe "surrounding the block" do

    before(:each) do
      class TestHelperModule::TestHelperSurround < ActionView::BlockHelper
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
  
  describe "block helpers with arguments" do
    before(:each) do
      class TestHelperModule::TestHelperWithArgs < ActionView::BlockHelper
        def initialize(id, klass)
          @id, @klass = id, klass
        end
        def hello
          %(<p class="#{@klass}" id="#{@id}">Hello</p>)
        end
      end
    end
    it "should use the args passed in" do
      eval_erb(%(
        <% test_helper_with_args('hello', 'there') do |r| %>
          <%= r.hello %>
        <% end %>
      )).should match_html(%(<p class="there" id="hello">Hello</p>))
    end
  end
  
end
