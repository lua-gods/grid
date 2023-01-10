-- this part finds a grid and calls grid_start function when its found
-- you dont need to think about it
local grid_start
local grid_number
events.WORLD_TICK:register(function()
    local grid = world.avatarVars()["e4b91448-3b58-4c1f-8339-d40f75ecacc4"]
    grid = world.avatarVars()["93ab815f-92ab-4ea0-a768-c576896c52a8"] --H
    -- print(grid)
    if grid and grid.grid_api and grid_number ~= grid.grid_number then
		grid_number = grid.grid_number
    	grid.grid_api(grid_start, function(err) print(err) end)
    end
end)

-- function called when grid found
-- here you can make your own modes
function grid_start(grid)
	-- name you want grid modes to have as prefix
	grid.name = "my_name"
	
	-- here you create a mode
	-- you call a grid:newMode function
	-- it takes 4 arguments: name of mode, init function, tick function, render function
	-- name of mode will have prefix that will be name you used and will have : in middle
	-- for example if your name is "my_name" and your mode is "my_amazing_mode" it will be turned into: "my_name:my_amazing_mode"
	-- you can replace functions with nil if you dont use them
	grid.newMode("my_amazing_mode",
    function(grid) -- init will be executed once when loading grid mode
        local size = grid:getSize()
        local texture = textures:newTexture("simple_texture", size, size)
        texture:fill(0,0, size, size, vec(0, 0, 0, 0))

        grid:setLayerCount(2)
        grid:setColor(vec(0.15, 0.15, 0.18), 2)
        grid:setTexture(texture, 1)

        grid:setDepth(0, 1) -- 0 is depth in blocks, 1 is layer
        grid:setDepth(16, 2) -- 16 is depth in blocks, 2 is layer
    end,
    function(grid) -- tick will be executed every tick
        local texture = textures["simple_texture"]
        local dimensions = texture:getDimensions()

        local pos = grid:getPos()

        for i, v in pairs(world.getPlayers()) do
            local offset = (v:getPos() - pos).xz
            if offset.x >= 0 and offset.y >= 0 and offset.x < dimensions.x and offset.y < dimensions.y then
                texture:setPixel(offset.x, offset.y, vec(1, 1, 1, 1))
            end
        end

        texture:update()
    end,
    function(delta, grid) -- render will be executed every render
        grid:setColor(vectors.hsvToRGB(world.getTime(delta) * 0.005, 0.5, 1), 1)
    end)
end

-- you can also override grid mode like this (only you will see it):
-- avatar:store("force_grid_mode", "my_name:my_amazing_mode")

-- oh and also in init, tick or render you can get all apis using:
-- grid:getApi()