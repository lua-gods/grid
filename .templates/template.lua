
local grid_start ,grid_stateID
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID ~= grid.grid_number then
            grid_stateID = grid.grid_number grid.grid_api(grid_start) end
        events.WORLD_TICK:remove("grid finder") 
    end-- GN's UUID
end,"grid finder")

function grid_start(grid)
	local myMode = grid.newMode("example:grid_mode")
    
    myMode.INIT:register(function()

    end)

    myMode.TICK:register(function ()
        
    end)

    myMode.RENDER:register(function (delta)
        
    end)
end