-- this part finds a grid and calls grid_start function when its found
-- you dont need to think about it
local grid_start
local grid_number
events.WORLD_TICK:register(function()
    local grid = world.avatarVars()["e4b91448-3b58-4c1f-8339-d40f75ecacc4"]
    -- grid = world.avatarVars()["93ab815f-92ab-4ea0-a768-c576896c52a8"] --H
    -- print(grid)
    if grid and grid.grid_api and grid_number ~= grid.grid_number then
		grid_number = grid.grid_number
    	grid.grid_api(grid_start, function(err) print(err) end)
    end
end)

local queue_draw = {}
local texture
local fore
local shadow
local floaty = 0
-- function called when grid found
-- here you can make your own modes
function grid_start(grid)
	-- name you want grid modes to have as prefix
	grid.name = "grid"
	
	-- here you create a mode
	-- you call a grid:newMode function
	-- it takes 4 arguments: name of mode, init function, tick function, render function
	-- name of mode will have prefix that will be name you used and will have : in middle
	-- for example if your name is "my_name" and your mode is "my_amazing_mode" it will be turned into: "my_name:my_amazing_mode"
	-- you can replace functions with nil if you dont use them
	grid.newMode("modelist",
    function(grid) -- init will be executed once when loading grid mode
        local size = grid:getSize()
        texture = textures:newTexture("modelistlist", size*20, size*20)
        fore = textures:newTexture("modelistlistfore", size*20, size*20)
        shadow = textures:newTexture("modelistshadow", size*20, size*20)
        texture:fill(0,0, size*20, size*20, vec(0, 0, 0, 0))
        shadow:fill(0,0, size*20, size*20, vec(0, 0, 0, 0))
        fore:fill(0,0, size*20, size*20, vec(0, 0, 0, 0))

        grid:setLayerCount(5)
        grid:setDepth(floaty, 1)
        grid:setTexture(texture, 1)
        grid:setTexture(fore, 2)
        grid:setDepth(floaty+0.02,2)
        grid:setTexture(fore, 3)
        grid:setDepth(floaty+0.04,3)
        grid:setTexture(shadow, 4)
        grid:setDepth(0.5,4)
        grid:setColor(vec(0.3,0.3,0.3), 5)
        grid:setDepth(0.5,5)
        
        local dimensions = texture:getDimensions()
        
        --warp text

        local offset = vec(0,0)
        local function print(text)
            local instructions = grid:textToPixels(text)
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
        print("wiki on how to make one coning soon?")
        print("")
        print("note that this does not dynamically")
        print("tell the current grid modes at")
        print("runtime, reload is required")
        print("to update the list.")

    end,function (grid)
        floaty = math.sin(world.getTimeOfDay()*0.1)*0.1-0.2
        grid:setDepth(floaty, 1)
        grid:setDepth(floaty+0.02,2)
        grid:setDepth(floaty+0.04,3)
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
end
-- you can also override grid mode like this (only you will see it):
-- avatar:store("force_grid_mode", "my_name:my_amazing_mode")

-- oh and also in init, tick or render you can get all apis using:
-- grid:getApi()