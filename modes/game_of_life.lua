
local grid_start ,grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            	grid_stateID[key] = grid.grid_number
            	grid.grid_api(grid_start)
            end
    end
end,"grid finder")

local config = {
    subdivide = 4,
    search = {
        vec(-1,-1),
        vec(-1,1),
        vec(1,1),
        vec(1,-1),
        vec(1,0),
        vec(-1,0),
        vec(0,1),
        vec(0,-1),
    },
    alive = vec(1,1,1,1),
    dead = vec(0,0,0,0),
    clock_speed = 5,
}

function grid_start(grid)
    ---@type gridMode
	local gol = grid.newMode("demo:gol")
    local size = gol:getGridSize()*config.subdivide
    local frame = textures:newTexture("golworld",size,size)
    local lastFrame = textures:newTexture("golshadowworld",size,size)
    gol.INIT:register(function ()
        gol:setLayerCount(10)
        
        lastFrame:fill(0,0,size,size,vec(0,0,0,1))
        frame:applyFunc(0,0,size,size,function (clr,x,y)
            if math.random(1,5) == 1 then
                return vec(1,1,1,1)
            else
                return vec(0,0,0,0)
            end
        end)
        
        for i = 1, 10, 1 do
            if i == 10 then
                gol:setLayerColor(vec(0.1,0.1,0.1),i)
            else
                gol:setLayerTexture(frame,i)
                if i ~= 1 then
                    gol:setLayerColor(vec(0.6,0.6,0.6),i)
                end
            end
            gol:setLayerDepth(i*0.03,i)
        end
        frame:update()
    end)
    local timer = 0
    local xpen, ypen = 0,0
    gol.TICK:register(function ()
        lastFrame:applyFunc(0,0,size,size,function (clr,x,y)
            return frame:getPixel(x,y)
        end)
        for i = 1, 200, 1 do
            xpen = xpen + 1
            if xpen >= size then
                xpen = 0
                ypen = ypen + 1
                if ypen >= size then
                    xpen = 0
                    ypen = 0
                    frame:update()
                end
            end
            
            local alive = (lastFrame:getPixel(xpen,ypen).x > 0.5)
            local adjacent = 0
            for key, offset in pairs(config.search) do
                local ox, oy = (xpen+offset.x)%size, (ypen+offset.y)%size
                if lastFrame:getPixel(ox,oy).x > 0.5 then
                    adjacent = adjacent + 1
                    if adjacent == 4 then
                        break
                    end
                end
            end
            if alive then -- alive
                if not (adjacent == 2 or adjacent == 3) then
                    frame:setPixel(xpen,ypen,config.dead)
                end
            else -- dead
                if adjacent == 3 then
                    frame:setPixel(xpen,ypen,config.alive)
                end
            end
            
        end
        
        lastFrame:setPixel(xpen,ypen,frame:getPixel(xpen,ypen))
        local pos = gol:getPos()
        for i, v in pairs(world.getPlayers()) do
            local offset = (v:getPos() - pos).xz * config.subdivide
            if offset.x >= 0 and offset.y >= 0 and offset.x < size and offset.y < size then
                frame:setPixel(offset.x, offset.y, vec(1, 1, 1, 1))
            end
        end
    end)
end