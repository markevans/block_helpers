require 'activesupport'
require 'action_view'

module BlockHelpers
  
  class BlockHelper
    
    def self.inherited(klass)
      # Define the helper method
      # e.g. for a class:
      #   class HelloHelper < BlockHelpers::BlockHelper
      #     #.....
      #   end
      #
      # then we define a helper method 'hello_helper'
      #
      method_name = klass.name.split('::').last.underscore
      klass.parent.class_eval %(      
        def #{method_name}(&block)
          renderer = #{klass.name}.new
          if renderer.respond_to? :render
            concat "asdf"
#            concat renderer.render(capture(renderer, &block))
          else
            block.call(renderer)
          end
        end
      )
    end
    
  end
  
end