module BlockHelpers
  
  class BlockHelper
    
    def self.inherited(klass)
      method_name = klass.name.split('::').last.underscore
      klass.parent.class_eval %(
        def #{method_name}(&block)
          block.call(#{klass.name}.new)
        end
      )
    end
    
  end
  
end