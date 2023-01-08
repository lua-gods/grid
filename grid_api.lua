-- grid api --
local grid_api = {}

local grid_api_metatable = {
    __index = grid_api,
    __newindex = function() end,
    __metatable = false,
}

local grid_api_to_name = {}

-- layers
local layers = {}

-- grid core functions
local grid_core_functions = {}


-- grid modes
local grid_modes = {current = "", last = ""}
local grid_mode_exist = {}

-- create grid
local function create_grid_api(name)
    local tbl = {}
    
    grid_api_to_name[tbl] = tostring(name):gsub(":", "")
    
    return setmetatable(tbl, grid_api_metatable)
end

avatar:store("grid_api", create_grid_api)

-- grid api functions --

-- basic info
do
    local list
    
    function grid_api:getApi()
        if not list then
            list = ""
            for i in pairs(grid_api) do
                list = list..i..", "
            end
            list = list:sub(1, -3)
        end
        return list
    end
end

function grid_api:getName()
    return grid_api_to_name[self]
end

function grid_api:getMode()
    return grid_modes.current
end

function grid_api:newMode(name)
    local mode_name = grid_api_to_name[self]..":"..tostring(name):gsub(":", "")
    if not grid_mode_exist[mode_name] then
        grid_mode_exist[mode_name] = true
        grid_modes[#grid_modes+1] = mode_name
    end
end

function grid_api:getPos()
    return grid_core_functions.pos()
end

function grid_api:getSize()
    return grid_core_functions.size()
end

function grid_api:isLoaded()
    return grid_core_functions.exist()
end

-- modify grid
function grid_api:canEdit()
    return grid_api_to_name[self] ~= nil and grid_api_to_name[self] == grid_modes.current:match("^(.*):")
end

---Sets the Texture of the layer selected.
---@param texture Texture
---@param layer integer
function grid_api:setTexture(texture, layer)
    if not self:canEdit() then
        error("Cannot edit texture, you are not creator of this mode", 2)
    end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.model:setPrimaryTexture("Custom", texture)
    end
end

---Sets the depth of the selected layer, if not given, default is 1.
---@param depth number
---@param layer integer
function grid_api:setDepth(depth, layer)
    if not self:canEdit() then
        error("Cannot edit depth, you are not creator of this mode", 2)
    end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.depth = tonumber(depth) or 1
    end
end

---Sets the Texture Dimensions.  
---GNs note: no clue what this is for
---@param texture_size integer
---@param layer integer
function grid_api:setTextureSize(texture_size, layer)
    if not self:canEdit() then
        error("Cannot edit texture size, you are not creator of this mode", 2)
    end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.texture_size = tonumber(texture_size) or 1
    end
end

---Sets the color of the layer, the same effect as modelPart:setColor().
---@param color Vector3
---@param layer integer
function grid_api:setColor(color, layer)
    if not self:canEdit() then
        error("Cannot edit color, you are not creator of this mode", 2)
    end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        if type(color) == "Vector3" then
            selected_layer.model:setColor(color)
        end
    end
end

---Sets the amount of layers the grid can use
---@param count integer
function grid_api:setLayerCount(count)
    if not self:canEdit() then
        error("Cannot edit layer count, you are not creator of this mode", 2)
    end

    count = tonumber(count) or 1
    for i = 1, #layers do
        if count >= i then
            layers[i].model:setVisible()
        else
            layers[i].model:setVisible(false)
        end
    end
end

-- return variables --
return grid_modes, grid_mode_exist, layers, grid_core_functions