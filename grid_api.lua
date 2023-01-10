-- grid api --
local grid_api = {}

local grid_api_metatable = {
    __index = grid_api,
    __metatable = false,
}

-- layers
local layers = {}

-- grid core functions
local grid_api_and_core_functions = {}

-- grid modes
local grid_modes = {}
local grid_modes_sorted = {}

local modes_to_add = nil
local function newMode(str, init, tick, render)
	if modes_to_add then
		modes_to_add[#modes_to_add+1] = {str, init, tick, render}
	end
end

local function sort_number(str)
    local a = (string.byte(str:sub(1, 1)) or 0) * 255 + (string.byte(str:sub(2, 2)) or 0)
	if str:match(":") then
        return a + (string.byte(str:match(":(.)") or "") or 0) / 255 + (string.byte(str:match(":.(.)") or "") or 0) / 65536
    end
    return a 
end

local function sort_grid_mode(str)
	local x = sort_number(str)
    local min, max = 1, math.max(#grid_modes_sorted, 1)
    local limit = 0
    while min ~= max and limit < 128 do
		limit = limit + 1
        local half = math.floor((min + max) / 2)
        if x >= sort_number(grid_modes_sorted[half]) then
            min = half + 1
        else
            max = half
        end
    end

    table.insert(grid_modes_sorted, min, str)
end

-- create grid
local function grid_init(func, error_func)
    if type(func) == "function" then
		local tbl = {newMode = newMode, name = "unknown"}
		modes_to_add = {}
		
    	func(tbl)
    	
    	local name = tostring(rawget(tbl, "name")):gsub(":", "")
    	local safe_api = setmetatable({}, grid_api_metatable)
    	for _, v in ipairs(modes_to_add) do
             local mode_name = name..":"..tostring(v[1]):gsub(":", "")
             
			if not grid_modes[mode_name] then
				sort_grid_mode(mode_name)
			end
             
			grid_modes[mode_name] = {safe_api, v[2], v[3], v[4], error_func}
		end

		mode_to_add = nil
    end
end

avatar:store("grid_api", grid_init)

-- random number for grid
avatar:store("grid_number", math.random())

-- can edit --
local can_edit = false
function grid_api_and_core_functions.can_edit(x)
    can_edit = x
end

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

function grid_api:getPos()
    return grid_api_and_core_functions.pos()
end

function grid_api:getSize()
    return grid_api_and_core_functions.size()
end

---Sets the Texture of the layer selected.
---@param texture Texture
---@param layer integer
function grid_api:setTexture(texture, layer)
    if not can_edit then return end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.model:setPrimaryTexture("Custom", texture)
    end
end

---Sets the depth of the selected layer, if not given, default is 1.
---@param depth number
---@param layer integer
function grid_api:setDepth(depth, layer)
    if not can_edit then return end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.depth = tonumber(depth) or 1
    end
end

---Sets the Texture Dimensions.  
---GNs note: no clue what this is for
---Aurias note: its just texture zoom
---@param texture_size integer
---@param layer integer
function grid_api:setTextureSize(texture_size, layer)
    if not can_edit then return end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.texture_size = tonumber(texture_size) or 1
    end
end

---Sets the color of the layer, the same effect as modelPart:setColor().
---@param color Vector3
---@param layer integer
function grid_api:setColor(color, layer)
    if not can_edit then return end

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
    if not can_edit then return end

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
return grid_modes, grid_modes_sorted, layers, grid_api_and_core_functions, grid_api