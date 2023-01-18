---@diagnostic disable: lowercase-global

local blacklist = {
   ""
}
local cache = {}
for _, path in pairs(listFiles("",true)) do
   local scriptName = ""
   for i = #path, 0, -1 do
      local char = path:sub(i,i)
      if char == "." then
         break
      end
      scriptName = char .. scriptName
   end
   if scriptName ~= "libraryfind" then
      cache[scriptName] = require(path)
   end
end

function requireLibrary(name)
   
end

print(cache)

requireLibrary("KattEventsAPI")