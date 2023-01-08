local config = {
   mapping = "`1234567890-=~!@#$%^&*()_+qwertyuiop[]QWERTYUIOP{}asdfghjkl;'ASDFGHJKL:\"zxcvbnm,./ZXCVBNM<>?\\|",
   path = "fontmap"
}
local fontmap = textures[config.path]
local baked_font = {}
local fontmap_size = fontmap:getDimensions()
local width = 0
local charID = 1
local char_font = {}
for x = 0, fontmap_size.x-1, 1 do
   width = width + 1
   local column = {}
   local gap = true
   for y = 0, fontmap_size.y-1, 1 do
      local p = fontmap:getPixel(x,y)
      if p.x > 0.5 then
         gap = false
         table.insert(column,true)
      else
         table.insert(column,false)
      end
   end
   if gap then
      baked_font[config.mapping:sub(charID,charID)] = {data=char_font,width = width}
      width = 0
      charID = charID + 1
      char_font = {}
   else
      table.insert(char_font,column)
   end
   baked_font[config.mapping:sub(charID,charID)] = {}
end