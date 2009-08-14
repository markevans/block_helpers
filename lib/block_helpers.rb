require 'activesupport'
require 'action_view'

module ActionView

  class BlockHelper

    attr_accessor :helper

    def initialize(template, *args)
      @helper = template
      self.options(*args) if self.respond_to?(:options)
    end

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
          renderer = #{klass.name}.new(self, *args)
          if renderer.public_methods(false).include? 'display'
            concat renderer.display(capture(renderer, &block))
          else
            block.call(renderer)
          end
        end
      )
    end

    def respond_to?(method)
      return true if helper.respond_to?(method)
      super
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
