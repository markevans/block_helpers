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
    
      class MyBlockHelper < BlockHelpers::BlockHelper
      
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

Using arguments
---------------

You can pass in arguments to the helper, and these will be passed through to the class's `initialize` method.
In the helper:

    module MyHelper

      class MyBlockHelper < BlockHelpers::BlockHelper
  
        def initialize(tag_type)
          @tag_type = tag_type
        end
  
        def hello(name)
          content_tag @tag_type, "Hi there #{name}!"
        end
  
      end

    end

In the view:

    <% my_block_helper(:span) do |h| %>
      <%= h.hello('Marmaduke') %>
    <% end %>

This generates:

    <span>Hi there Marmaduke!</span>
    
Note that methods available in the helper (e.g. `content_tag`) are also available in the block helper class.

Surrounding markup
------------------

Use the `to_s` method to surround the block with markup, e.g.
In the helper:

    module MyHelper

      class RoundedBox < BlockHelpers::BlockHelper

        def to_s(body)
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
    
== Copyright

Copyright (c) 2009 Mark Evans. See LICENSE for details.
