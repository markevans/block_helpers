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
          body = block ? capture(renderer, &block) : nil
          processed_body = renderer.display(body)
          if processed_body
            if method(:concat).arity == 2
              concat processed_body, binding
            else
              concat processed_body
            end
          end
          renderer
        end
      )
    end

    def display(body)
      body
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
