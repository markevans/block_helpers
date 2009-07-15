module BlockHelpers

  protected
  
  def block_helper(name, &block)
    
    # Define the class for the yielded object
    klass = Class.new
    klass.class_eval(&block)
    
    # Define the method which the user will call
    self.class_eval %(
      def #{name}(&blk)
        blk.call(23.3)
      end
    )
  end
  
end