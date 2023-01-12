-- this part finds a grid and calls grid_start function when its found
-- you dont need to think about it
local grid_start ,grid_stateID
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID ~= grid.grid_number then
            grid_stateID = grid.grid_number grid.grid_api(grid_start) end
    end-- GN's UUID
end,"grid finder")

local queue_draw = {}
local texture
local fore
local shadow
local floaty = 0
-- function called when grid found
-- here you can make your own modes
function grid_start(grid)
	-- here you create a mode
	-- you call a grid:newMode function
	-- it takes 4 arguments: name of mode, init function, tick function, render function
	-- name of mode will have prefix that will be name you used and will have : in middle
	-- for example if your name is "my_name" and your mode is "my_amazing_mode" it will be turned into: "my_name:my_amazing_mode"
	-- you can replace functions with nil if you dont use them
	local modelist = grid.newMode("grid:modelist")
    modelist.INIT:register(function() -- init will be executed once when loading grid mode
        local size = modelist:getGridSize()
        
        texture = textures:newTexture("modelistlist", size*20, size*20)
        fore = textures:newTexture("modelistlistfore", size*20, size*20)
        shadow = textures:newTexture("modelistshadow", size*20, size*20)
        texture:fill(0,0, size*20, size*20, vec(0, 0, 0, 0))
        shadow:fill(0,0, size*20, size*20, vec(0, 0, 0, 0))
        fore:fill(0,0, size*20, size*20, vec(0, 0, 0, 0))

        modelist:setLayerCount(5)
        modelist:setLayerDepth(floaty, 1)
        modelist:setLayerTexture(texture, 1)
        modelist:setLayerTexture(fore, 2)
        modelist:setLayerDepth(floaty+0.02,2)
        modelist:setLayerTexture(fore, 3)
        modelist:setLayerDepth(floaty+0.04,3)
        modelist:setLayerTexture(shadow, 4)
        modelist:setLayerDepth(0.5,4)
        modelist:setLayerColor(vec(0.3,0.3,0.3), 5)
        modelist:setLayerDepth(0.5,5)
        
        local dimensions = texture:getDimensions()
        
        --warp text

        local offset = vec(0,0)
        local function print(text)
            local instructions = modelist:textToPixels(text)
            for key, letter in pairs(instructions) do
                if offset.x+letter.width >= dimensions.x then
                    offset.x = 0
                    offset.y = offset.y + 8
                end
                for _, pen in pairs(letter.data) do
                    table.insert(queue_draw,vec(pen.x+offset.x,pen.y+offset.y))
                end
                offset.x = offset.x + letter.width
            end
            offset.x = 0
            offset.y = offset.y + 8
        end
        print("GN & Auria's Grid 2.0")
        print("List of Currently Available Grid Modes:")
        print(">-------------------------------")
        local _,list = require "grid_api"
        for key, value in pairs(list) do
            print("| "..value)
        end
        print(">-------------------------------")
        print("Progress:")
        print("[  ] PRESETNATION!")
        print("[  ] Dynamic modelist updating")
        print("[  ] Documentation")
        print("[X] Figura my beloved")
        print("[X] Events Integration")
    end)

    modelist.RENDER:register(function (delta)
        floaty = math.sin(client:getSystemTime()*0.002)*0.1
        modelist:setLayerDepth(floaty, 1)
        modelist:setLayerDepth(floaty+0.02,2)
        modelist:setLayerDepth(floaty+0.04,3)
        local function setPixel(x,y,toggle)
            if toggle then
                texture:setPixel(x,y,vec(1,1,1))
                shadow:setPixel(x,y,vec(0,0,0,0.5))
                fore:setPixel(x,y,vec(0.5,0.5,0.5,1))
            else
                texture:setPixel(x,y,vec(1,1,1,0))
                shadow:setPixel(x,y,vec(0,0,0,0))
                fore:setPixel(x,y,vec(0.5,0.5,0.5,0))
            end
        end
        for i = 1, 20, 1 do
            if #queue_draw > 0 then
                local chosen = math.random(1,math.min(#queue_draw,50))
                local pen = queue_draw[chosen]
                setPixel(pen.x,pen.y,true)
                table.remove(queue_draw,chosen)
                texture:update()
                shadow:update()
                fore:update()
            end
        end
    end)
    --[[
        ,)
    ]]
end
-- you can also override grid mode like this (only you will see it):
-- avatar:store("force_grid_mode", "my_name:my_amazing_mode")

-- oh and also in init, tick or render you can get all apis using:
-- grid:getApi()