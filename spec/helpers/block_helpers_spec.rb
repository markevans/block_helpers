require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module TestHelperModule
end

describe TestHelperModule do

  describe "simple block_helper" do
    
    before(:each) do
      module TestHelperModule
        remove_const(:TestHelper) if defined?(TestHelper)
        class TestHelper < BlockHelpers::Base
          def hello
            'Hi there'
          end
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
    
    it "should do nothing if no block given" do
      eval_erb(%(
        <% test_helper %>
      )).should match_html("")
    end
    
    it "should return itself (the renderer object)" do
      eval_erb(%(
        <% e = test_helper %>
        <%= e.hello %>
      )).should match_html('Hi there')
    end
    
  end
  
  describe "access to other methods" do
    before(:each) do
      module TestHelperModule

        def yoghurt
          'Yoghurt'
        end
        
        remove_const(:TestHelper) if defined?(TestHelper)
        class TestHelper < BlockHelpers::Base
          def yog
            yoghurt[0..2]
          end
          def jelly_in_div
            content_tag :div, 'jelly'
          end
          def cheese
            helper.cheese[0..3]
          end
          def label_tag(text)
            helper.label_tag(text[0..1])
          end
          def check_capture(&block)
            string = capture(&block)
            2.times{ concat(string) }
          end
        end
        
        def cheese
          'Cheese'
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
    it "should give the yielded renderer access to normal actionview helper methods even in initialize" do
      module TestHelperModule
        class JokeHelper < BlockHelpers::Base
          def initialize
            @joke = truncate("What's the different between half a duck?", :length => 6)
          end
          attr_reader :joke
        end
      end
      eval_erb(%(
        <% joke_helper do |r| %>
          <%= r.joke %>
        <% end %>
      )).should match_html("Wha...")
    end
    it "should give the yielded renderer access to other methods via 'helper'" do
      eval_erb(%(
        <% test_helper do |r| %>
          <%= r.cheese %>
        <% end %>
      )).should match_html("Chee")
    end
    it "should give the yielded renderer access to normal actionview helper methods via 'helper'" do
      eval_erb(%(
        <% test_helper do |r| %>
          <%= r.label_tag 'hide' %>
        <% end %>
      )).should match_html('<label for="hi">Hi</label>')
    end
    it "should work with methods like 'capture'" do
      eval_erb(%(
        <% test_helper do |r| %>
          <% r.check_capture do %>
            HELLO
          <% end %>
        <% end %>
      )).should match_html('HELLO HELLO')
    end
  end
  
  describe "accessibility" do
    def run_erb
      eval_erb(%(
        <% compat_helper do |r| %>
          HELLO
        <% end %>
      ))
    end

    it "should work when concat has one arg" do
      module TestHelperModule
        def concat(html); super(html); end
        remove_const(:CompatHelper) if defined?(CompatHelper)
        class CompatHelper < BlockHelpers::Base
          def display(body)
            "Before...#{body}...after"
          end
        end
      end
      run_erb.should match_html("Before... HELLO ...after")
    end
    it "should work when concat has two args" do
      module TestHelperModule
        def concat(html, binding); super(html); end
        remove_const(:CompatHelper) if defined?(CompatHelper)
        class CompatHelper < BlockHelpers::Base
          def display(body)
            "Before...#{body}...after"
          end
        end
      end
      run_erb.should match_html("Before... HELLO ...after")
    end
    it "should work when concat has one optional arg" do
      module TestHelperModule
        def concat(html, binding=nil); super(html); end
        remove_const(:CompatHelper) if defined?(CompatHelper)
        class CompatHelper < BlockHelpers::Base
          def display(body)
            "Before...#{body}...after"
          end
        end
      end
      run_erb.should match_html("Before... HELLO ...after")
    end
  end
  
  describe "surrounding the block" do

    before(:each) do
      module TestHelperModule
        remove_const(:TestHelperSurround) if defined?(TestHelperSurround)
        class TestHelperSurround < BlockHelpers::Base
          def display(body)
            if body.nil?
              "This is nil!"
            else
              %(
                <p>Before</p>
                #{body}
                <p>After</p>
              )
            end
          end
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
    it "should pass in the body as nil if no block given" do
      eval_erb(%(
        <% test_helper_surround %>
      )).should match_html("This is nil!")
    end
  end
  
  describe "block helpers with arguments" do
    before(:each) do
      module TestHelperModule
        remove_const(:TestHelperWithArgs) if defined?(TestHelperWithArgs)
        class TestHelperWithArgs < BlockHelpers::Base
          def initialize(id, klass)
            @id, @klass = id, klass
          end
          def hello
            %(<p class="#{@klass}" id="#{@id}">Hello</p>)
          end
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
  
  describe "inheritance" do
    
    before(:each) do
      module TestHelperModule
        remove_const(:ParentTestHelper) if defined?(ParentTestHelper)
        remove_const(:ChildTestHelper) if defined?(ChildTestHelper)
        class ParentTestHelper < BlockHelpers::Base
          def hello
            "hello"
          end
        end
        class ChildTestHelper < ParentTestHelper
        end
      end
    end
    
    it "should inherit normal methods" do
      eval_erb(%(
        <% child_test_helper do |r| %>
          <%= r.hello %>
        <% end %>
      )).should match_html("hello")
    end
    
    it "should inherit the 'display' method" do
      TestHelperModule::ParentTestHelper.class_eval do
        def display(body)
          "before...#{body}...after"
        end
      end
      eval_erb(%(
        <% child_test_helper do %>
          hello
        <% end %>
      )).should match_html("before... hello ...after")
    end
    
  end
  
  describe "when display returns 'nil'" do
    it "should output nothing" do
      module TestHelperModule
        remove_const(:NilHelper) if defined?(NilHelper)
        class NilHelper < BlockHelpers::Base
          def display(body)
          end
        end
      end
      eval_erb(%(
        <% nil_helper do %>
          hello
        <% end %>
      )).should match_html("")
    end
  end
  
  describe "nested block helpers" do
    it "should define a nested block helper method" do
      module TestHelperModule
        class OuterHelper < BlockHelpers::Base
          
          def egg
            'bad egg ' + parent.inspect
          end
          
          def display(body)
            "Outer #{body}"
          end
          
          class InnerHelper < BlockHelpers::Base
            
            def initialize
              @egg = parent.egg
            end
            
            def egg
              @egg + ' ' + parent.egg.upcase
            end
            def display(body)
              "Inner #{body}"
            end
          end
        end
      end
      eval_erb(%(
        <% outer_helper do |o| %>
          <% o.inner_helper do |i| %>
            <%= i.egg %>
          <% end %>
        <% end %>
      )).should match_html("Outer Inner bad egg nil BAD EGG NIL")
    end
  end
  
end
