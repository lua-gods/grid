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
        texture:fill(0,0, size*20, size*20, vec(0, 0, 0, 0))

        grid:setLayerCount(2)
        grid:setColor(vec(0.1,0.1,0.1), 2)
        grid:setTexture(texture, 1)
        grid:setDepth(1,2)

        grid:setDepth(0, 1) -- 0 is depth in blocks, 1 is layer
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
        print("List of Grid Modes:")
        print(">---------------")
        local _,list = require "grid_api"
        for key, value in pairs(list) do
            print("| "..value)
        end

    end,function ()
        for i = 1, 10, 1 do
            if queue_draw[1] then
                local pen = queue_draw[1]
                texture:setPixel(pen.x,pen.y,vec(1,1,1))
                table.remove(queue_draw,1)
                texture:update()
            end
        end
    end)
end
-- you can also override grid mode like this (only you will see it):
-- avatar:store("force_grid_mode", "my_name:my_amazing_mode")

-- oh and also in init, tick or render you can get all apis using:
-- grid:getApi()