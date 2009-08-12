Block Helpers
=============

When we write ERB views in Rails, etc., we generally DRY up the markup using helpers or partials.

However, it's quite common to overdo the 'DRYing up'.

When you find yourself passing in optional arguments to a helper/partial such as `:extra_text => 'eggs', :to_s_method => 'cheese'`, you know that there must be a better way.

Rails already has a great solution for forms with form-builders, using helpers which yield an object which can be used for further rendering.

This small gem generates helpers similar to the form-builders, but for the general case.

Example usage
=============
Please note that these examples are very contrived just for brevity! These block helpers are much more useful than just printing 'Hi there Marmaduke!'

Simple case
-----------

In the helper file:

    module MyHelper
    
      class MyBlockHelper < ActionView::BlockHelper
      
        def hello(name)
          "<p>Hi there #{name}!</p>"
        end
      
      end
    
    end

This has generated a helper called `my_block_helper`.
So in the view:

    <% my_block_helper do |h| %>
      Here goes...
      <%= h.hello('Marmaduke') %>
      ...hooray!
    <% end %>

This will generate the following:

    Here goes...
    <p>Hi there Marmaduke!</p>
    ...hooray!


Accessing other helper methods
------------------------------

Methods available in the parent helper are available to the block helper class via the protected object `helper` (see use of `content_tag` below).

Using arguments
---------------

You can pass in arguments to the helper, and these will be passed through to the class's `initialize` method.
In the helper:

    module MyHelper

      class MyBlockHelper < ActionView::BlockHelper
  
        def initialize(tag_type)
          @tag_type = tag_type
        end
  
        def hello(name)
          helper.content_tag @tag_type, "Hi there #{name}!"
        end
  
      end

    end

In the view:

    <% my_block_helper(:span) do |h| %>
      <%= h.hello('Marmaduke') %>
    <% end %>

This generates:

    <span>Hi there Marmaduke!</span>

Surrounding markup
------------------

Use the `render` method to surround the block with markup, e.g.
In the helper:

    module MyHelper

      class RoundedBox < ActionView::BlockHelper

        def render(body)
          %(
            <div class="tl">
              <div class="tr">
                <div class="bl">
                  <div class="br">
                    #{body}
                  </div>
                </div>
              </div>
            </div>
          )
        end

      end

    end

In the view:

    <% rounded_box do %>
      Oi oi!!!
    <% end %>

This generates:

    <div class="tl">
      <div class="tr">
        <div class="bl">
          <div class="br">
            Oi oi!!!
          </div>
        </div>
      </div>
    </div>

Of course, you could use `render` for more than just surrounding markup.

Installation
============

To use in Rails, add to your `environment.rb`:

    config.gem "markevans-block_helpers", :lib => "block_helpers", :source => "http://gems.github.com"

Copyright
========

Copyright (c) 2009 Mark Evans. See LICENSE for details.
