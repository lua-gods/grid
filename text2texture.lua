local b2t = {}
local config = {
   mapping = "`1234567890-=~!@#$%^&*()_+qwertyuiop[]QWERTYUIOP{}asdfghjkl;'ASDFGHJKL:\"zxcvbnm,./ZXCVBNM<>?\\|",
   path = ".src.fontmap"
}
local fontmap = textures[config.path]
local baked_font = {}
local fontmap_size = fontmap:getDimensions()
local width = 0
local charID = 1
local char_font = {}
for scanX = 0, fontmap_size.x-1, 1 do
   width = width + 1
   local column = {}
   local gap = true
   for scanY = 0, fontmap_size.y-1, 1 do
      local p = fontmap:getPixel(scanX,scanY)
      if p.x > 0.5 then
         gap = false
         table.insert(char_font,vec(width,scanY*-1+fontmap_size.y))
      end
   end
   if gap then
      baked_font[config.mapping:sub(charID,charID)] = {data=char_font,width = width}
      width = 0
      charID = charID + 1
      char_font = {}
   end
   baked_font[config.mapping:sub(charID,charID)] = {}
end

print(baked_font.A.data)

---@param text string
function b2t:text2pixels(text)
   for i = 1, text:len(), 1 do
      local char = text:sub(i,i)

   end
end

return b2t