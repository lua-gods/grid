
local dummy_event = {}
function dummy_event:register(func,name)
end
function dummy_event:remove(name)
end

---@class gridMode
local gridMode = {INIT=dummy_event,TICK=dummy_event,RENDER=dummy_event}

---Returns the position of the grid
---@return Vector3
function gridMode:getPos()
   return vectors.vec3()
end

---Returns the dimensions of the grid
---@return integer
function gridMode:getGridSize()
    return 0
end

---Returns the Max amount of layers the grid can handle (32)
---@return integer
function gridMode:getMaxLayers()
    return 32
end

---Sets the Texture of the layer selected.
---@param texture Texture
---@param layer integer
function gridMode:setLayerTexture(texture, layer)
end

---Sets the depth of the selected layer, if not given, default is 1.
---@param depth number
---@param layer integer
function gridMode:setLayerDepth(depth, layer)
end

---Sets the Texture Dimensions.  
---GNs note: no clue what this is for
---Aurias note: its just texture zoom
---@param texture_size integer
---@param layer integer
function gridMode:setTextureSize(texture_size, layer)
end

---Sets the color of the layer, the same effect as modelPart:setColor().
---@param color Vector3
---@param layer integer
function gridMode:setLayerColor(color, layer)
end

---Sets the amount of layers the grid can use
---@param count integer
function gridMode:setLayerCount(count)
end

---Converts the String into a table of character data  
---***
---### Character Structure
---{  
---    data={pos array},  
---    width=int  
---}   
---@param text any
---@return table
function gridMode:textToPixels(text)
   return {}
end