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
        def #{method_name}(*args, &block)
          renderer = #{klass.name}.new(*args)
          if renderer.public_methods(false).include? 'to_s'
            concat renderer.to_s(capture(renderer, &block))
          else
            block.call(renderer)
          end
        end
      )
      klass.class_eval do
        include klass.parent
      end
    end
    
  end
  
end