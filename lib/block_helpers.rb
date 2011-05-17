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
            if self.is_a?(BlockHelpers::Base) 
              top_level_helper = self.helper
              parent_block_helper = self
            else
              top_level_helper = self
              parent_block_helper = nil
            end
            
            # We need to save the current helper and parent block helper in the class so that
            # it's visible to the renderer's 'initialize' method...
            #{klass.name}.current_helper = top_level_helper
            #{klass.name}.current_parent_block_helper = parent_block_helper
            renderer = #{klass.name}.new(*args)
            # ...then set them anyway on the renderer so that renderer methods can use it
            renderer.send(:helper=, top_level_helper)
            renderer.send(:parent=, parent_block_helper)

            body = block ? capture(renderer, &block) : nil
            processed_body = renderer.display(body)
            if processed_body

              # If riding on Rails 2.x use old concat syntax
              if ::Rails::VERSION::MAJOR <= 2
                concat processed_body, binding
              # ...otherwise call with one arg or use Rails3 block helper style (requires <%= %> at block invocation)
              else
                if renderer.rails2_compatibility_mode? 
                  concat(processed_body)
                else
                  return processed_body
                end
              end
              
            end
            renderer
          end
        )
      end
      
      attr_accessor :current_helper, :current_parent_block_helper
    
    end

    def display(body)
      body
    end
    
    def respond_to?(method)
      super or helper.respond_to?(method)
    end

    # redefine this method either at Rails initialization or at each custom block class
    # to fall back to Rails 2.x helper sytnax (<% %>; without the '=' sign)
    def rails2_compatibility_mode?
      false
    end

    protected

    attr_writer :helper, :parent

    # For nested block helpers
    def parent
      @parent ||= self.class .current_parent_block_helper
    end
    
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
