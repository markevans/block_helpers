require 'activesupport'
require 'action_view'

module ActionView
  
  class BlockHelper
    
    def self.inherited(klass)
      # Define the helper method
      # e.g. for a class:
      #   class HelloHelper < ActionView::BlockHelper
      #     #.....
      #   end
      #
      # then we define a helper method 'hello_helper'
      #
      method_name = klass.name.split('::').last.underscore
      klass.parent.class_eval %(      
        def #{method_name}(*args, &block)
          renderer = #{klass.name}.new(*args)
          if renderer.public_methods(false).include? 'display'
            concat renderer.display(capture(renderer, &block))
          else
            block.call(renderer)
          end
        end
      )
      
      # Make a 'helper' object available, for calling
      # other helper methods / action view helpers,
      # in case of name clashes
      klass.class_eval do
        
        include klass.parent
        include ActionView::Helpers
        
        protected
        define_method :helper do
          if @helper.nil?
            @helper = Object.new
            # Open the singleton class of @helper, while
            # keeping 'klass' visible
            class << @helper; self; end.class_eval do
              include klass.parent
              include ActionView::Helpers
            end
          end
          @helper
        end

      end
    end
    
  end
  
end