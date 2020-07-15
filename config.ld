file={'lua/plugin/nakama.lua'}
dir='docs/'
project='Nakama'
title='Solar2d Nakama Plugin'
description='API Documentation for Solar2d Nakama Plugin'

full_description = [[
API Documentation for the Solar2d Nakama Plugin.
The plugin is a combination of 3rd Party and custom code.
This documentation is meant to help reduce code redundancy as well as increase 
maintainability.
]]

no_summary = false
no_return_or_parms = false
format=markdown

-- define a @callback tag:
custom_tags = { { 'callback', hidden = true } }

-- show a label beside functions tagged with @callback.
custom_display_name_handler = function(item, default_handler)
  if item.type == 'function' and item.tags.callback then
    return item.name .. ' [callback]'
  end
  return default_handler(item)
end
