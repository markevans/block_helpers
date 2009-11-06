require 'activesupport'

module BlockHelpers

  class Base

    class << self

      def inherited(klass)
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
            
            # Get the current helper object which has all the normal helper methods
            top_level_helper = if self.is_a?(BlockHelpers::Base) 
              self.helper
            else
              self
            end
            
            # We need to save the current helper in the class so that
            # it's visible to the renderer's 'initialize' method...
            #{klass.name}.current_helper = top_level_helper
            renderer = #{klass.name}.new(*args)
            # ...then set it anyway on the renderer so that renderer methods can use it
            renderer.send(:helper=, top_level_helper)
            
            body = block ? capture(renderer, &block) : nil
            processed_body = renderer.display(body)
            if processed_body

              # If concat is the old rails/merb version with 2 args...
              if top_level_helper.method(:concat).arity == 2
                concat processed_body, binding
              # ...otherwise call with one arg
              else
                concat processed_body
              end
              
            end
            renderer
          end
        )
      end
      
      attr_accessor :current_helper
    
    end

    def display(body)
      body
    end
    
    def respond_to?(method)
      super or helper.respond_to?(method)
    end

    protected

    attr_writer :helper
    
    def helper
      @helper ||= self.class.current_helper
    end

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
