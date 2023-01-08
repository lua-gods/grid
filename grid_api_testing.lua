require "grid_core"

local grid = world.avatarVars()["e4b91448-3b58-4c1f-8339-d40f75ecacc4"]
if grid then
    grid = grid.grid_api("GN") -- ask for grid api, you can replace uuid with your name
else
    return -- no grid found
end

-- print(grid:getName())
grid:newMode("nya")


local my_mode = false

local texture
local size

function uuidToColor(uuid)
    return vectors.hsvToRGB(tonumber("0x"..uuid:sub(16, 17))/255, tonumber("0x"..uuid:sub(6, 7))/510 + 0.5, 1)
end

local function grid_init()
    if not texture then   
        size = grid:getSize()
        texture = textures:newTexture("My first grid mode", size, size)
        texture:fill(0, 0, size, size, vec(0, 0, 0, 0))
    end

    grid:setTexture(texture)

    grid:setDepth(1)

    grid:setLayerCount(2)
    
    grid:setDepth(4, 2)
    grid:setTextureSize(2, 2)

    grid:setColor(vec(0.15, 0.15, 0.15), 2)
end

events.TICK:register(function()
    local can_edit = grid:canEdit() and grid:getMode() == "GN:nya"
    if can_edit then
        if not my_mode then
            my_mode = true
            grid_init()
        end

        local grid_pos = grid:getPos()
        for _, v in pairs(world.getPlayers()) do
            local offset = (v:getPos() - grid_pos).xz
            if offset.x >= 0 and offset.y >= 0 and offset.x < size and offset.y < size then
                texture:setPixel(offset.x, offset.y, uuidToColor(v:getUUID()))
            end
        end

        texture:update()
    else
        my_mode = false
    end
end)

events.RENDER:register(function(delta)
    if grid:canEdit() then
        grid:setDepth(math.cos(world.getTime(delta) * 0.1))
    end
end)