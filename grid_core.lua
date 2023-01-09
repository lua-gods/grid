local config = {
    model = models.grid.Skull,
    match_block = "minecraft:iron_block",
    match_offset = vec(0, -2, 0),
    grid_render_offset = vec(0, 0, 0),
    special_signs_pos = {
        vec(1, 0, 0),
        vec(-1, 0, 0),
        vec(0, 0, 1),
        vec(0, 0, -1),
        vec(0, -1, 0),
    },
    default_texture = textures["grid.grid"],
}

local grid_modes, grid_mode_exist, layers, grid_core_functions = require "grid_api"

config.model:setLight(15, 15)

-- grid basic info
local grid_head_update_time = 0
local grid_pos = vec(0, 0, 0)
local grid_size = 0

local grid_mode_sign_pos = vec(0, 0, 0)

-- grid layers
for i, v in pairs(config.model.grid:getChildren()) do
    layers[i] = {model = v}
end

local function reset_grid_layers()
    for i = 1, #layers do
        layers[i].depth = 2
        layers[i].texture_size = 1
        layers[i].model:setPrimaryTexture("Custom", config.default_texture)
        layers[i].model:setColor(1, 1, 1)
        layers[i].model:setVisible(false)
    end
    layers[1].model:setVisible()
end

-- find grid
function events.skull_render(delta, block)
    local isGrid = false

    if block and block.id == "minecraft:player_head" and block.properties and block.properties.rotation then
    local pos = block:getPos()

        local grid_start = 0
        for _ = 1, 32 do
            grid_start = grid_start - 1
            if world.getBlockState(pos + vec(grid_start, 0, grid_start) + config.match_offset).id ~= config.match_block then
                grid_start = grid_start + 1
                break
            end
        end
        
        local grid_end = 0
        for _ = 1, 32 do
            grid_end = grid_end + 1
            if world.getBlockState(pos + vec(grid_end, 0, grid_end) + config.match_offset).id ~= config.match_block then
                grid_end = grid_end - 1
                break
            end
        end

        if grid_start <= -1 and grid_end >= 1 then
            -- grid found
            grid_pos = pos + vec(grid_start, 0, grid_start) + config.grid_render_offset
            grid_size = grid_end - grid_start + 1

            grid_head_update_time = 100

            -- set model
            isGrid = true

            config.model.grid:setPos((grid_pos - pos) * 16)
            config.model.grid:setScale(grid_size, 1, grid_size)
            config.model:setRot(0, block.properties.rotation * 22.5, 0)

            --find signs
            for _, v in ipairs(config.special_signs_pos) do
                local bl = world.getBlockState(pos + v + config.match_offset)
                if bl.id:match("sign") then
                    local data = bl:getEntityData()
                    if data then
                        if data.Text1:match("grid_mode") then
                            local x, y, z = tonumber(data.Text2:match("[%d-.]+")) or 0, tonumber(data.Text3:match("[%d-.]+")) or 0, tonumber(data.Text4:match("[%d-.]+")) or 0
                            if x and y and z then
                                if data.Text2:match("~") then x = x + grid_pos.x end
                                if data.Text3:match("~") then y = y + grid_pos.y end
                                if data.Text4:match("~") then z = z + grid_pos.z end
                                grid_mode_sign_pos = vec(x, y, z)
                            end
                        end
                    end
                end
            end
        end
    end

    config.model:setVisible(isGrid)
end

-- update grid
function events.world_tick()
    if grid_head_update_time == 0 then
        return
    end
    grid_head_update_time = grid_head_update_time - 1

    -- get grid mode
    local bl = world.getBlockState(grid_mode_sign_pos)
    if bl.id:match("sign") then
        local data = bl:getEntityData()
        if data then
            grid_modes.current = (tostring(data.Text1):match('{"text":"(.*)"}') or "")..
                                 (tostring(data.Text2):match('{"text":"(.*)"}') or "")..
                                 (tostring(data.Text3):match('{"text":"(.*)"}') or "")..
                                 (tostring(data.Text4):match('{"text":"(.*)"}') or "")
        end

    end

    -- update grid when grid mode changed
    if grid_modes.current ~= grid_modes.last then
        grid_modes.last = grid_modes.current

        reset_grid_layers()
    end
end

-- set uv
local function setGridUV(offset, layer, i, layer_space)
    local matrix = matrices.mat3()

    local size = (1 / offset.y) * math.max(layer.depth or 0, 0) + 1

    local translate = offset.xz / -grid_size

    matrix:translate(translate)
    matrix:scale(size, size)
    matrix:translate(-translate)
    
    matrix:translate(-0.5, -0.5)
    matrix:scale(layer.texture_size or 1, layer.texture_size or 1)
    matrix:translate(0.5, 0.5)

    layer.model:setUVMatrix(matrix)

    layer.model:setPos(0, math.max(-(layer.depth or 0), (#layers - i + 1) * layer_space) * 16, 0)
end

-- render grid
function events.world_render(delta)
    if grid_head_update_time == 0 then
        return
    end

    local offset = client:getCameraPos() - grid_pos

    local distance = math.max(
        offset:length(),
        offset:copy():add(-grid_size, 0, 0):length(),
        offset:copy():add(0, 0, -grid_size):length(),
        offset:copy():add(-grid_size, 0, -grid_size):length()
    )

    
    local layer_space = math.clamp(distance * 0.0001, 0.001, 0.005)

    for i = 1, #layers do
        setGridUV(offset, layers[i], i, layer_space)
    end
end

-- grid core functions for grid api
function grid_core_functions.pos()
    return grid_pos
end

function grid_core_functions.size()
    return grid_size
end

function grid_core_functions.exist()
    return grid_head_update_time >= 1
end