-- grid api --
local grid_api = {}

local grid_api_metatable = {
    __index = grid_api,
    __newindex = function() return end,
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
    local tbl = grid_api
    
    grid_api_to_name[tbl] = tostring(name):gsub(":", "")
    
    return setmetatable(tbl, grid_api_metatable)
end

avatar:store("grid_api", create_grid_api)

-- grid api functions --

-- basic info
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
    return grid_api_to_name[self] == grid_modes.current:match("^(.*):")
end

function grid_api:setTexture(texture, layer_to_edit)
    if not self:canEdit() then
        error("Cannot edit texture, you are not creator of this mode", 2)
    end

    local layer = layers[layer_to_edit or 1]
    if layer then
        layer.model:setPrimaryTexture("Custom", texture)
    end
end

function grid_api:setDepth(depth, layer_to_edit)
    if not self:canEdit() then
        error("Cannot edit texture, you are not creator of this mode", 2)
    end

    local layer = layers[layer_to_edit or 1]
    if layer then
        layer.depth = tonumber(depth) or 1
    end
end

function grid_api:setTextureSize(texture_size, layer_to_edit)
    if not self:canEdit() then
        error("Cannot edit texture, you are not creator of this mode", 2)
    end

    local layer = layers[layer_to_edit or 1]
    if layer then
        layer.texture_size = tonumber(texture_size) or 1
    end
end

function grid_api:setColor(color, layer_to_edit)
    if not self:canEdit() then
        error("Cannot edit texture, you are not creator of this mode", 2)
    end

    local layer = layers[layer_to_edit or 1]
    if layer then
        if type(color) == "Vector3" then
            layer.model:setColor(color)
        end
    end
end

function grid_api:setLayerCount(count)
    if not self:canEdit() then
        error("Cannot edit texture, you are not creator of this mode", 2)
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