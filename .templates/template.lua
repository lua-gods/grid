local grid_start ,grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            	grid_stateID[key] = grid.grid_number
            	grid.grid_api(grid_start)
            end
    end
end,"grid finder")

function grid_start(grid)
    ---@type gridMode
	local myMode = grid.newMode("example:grid_mode")
    
    myMode.INIT:register(function()

    end)

    myMode.TICK:register(function ()
        
    end)

    myMode.RENDER:register(function (delta)
        
    end)
end
