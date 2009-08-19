require 'activesupport'

module BlockHelpers

  class Base

    def self.inherited(klass)
      # Define the helper method
      # e.g. for a class:
      #   class HelloHelper < BlockHelpers::Base
      #     #.....
      #   end
      #
      # then we define a helper method 'hello_helper'
      #
      method_name = klass.name.split('::').last.underscore
      klass.parent.class_eval %(
        def #{method_name}(*args, &block)
          renderer = #{klass.name}.new(*args)
          renderer.send(:helper=, self)
          if renderer.public_methods(false).include? 'display'
            if method(:concat).arity == 1
              concat renderer.display(capture(renderer, &block))
            else
              concat renderer.display(capture(renderer, &block)), binding
            end
          else
            block.call(renderer)
          end
        end
      )
    end

    def respond_to?(method)
      super or helper.respond_to?(method)
    end

    protected

    attr_accessor :helper

    def method_missing(method, *args, &block)
      if helper.respond_to?(method)
        self.class_eval "def #{method}(*args, &block); helper.send('#{method}', *args, &block); end"
        self.send(method, *args, &block)
      else
        super
      end
    end
    
  end

end
