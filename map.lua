local pairs = pairs
local char = string.char

local CHARACTER_VALUES = {
    {200, "🫂"}, {50, "💖"}, {10, "✨"}, {5, "🥺"}, {1, ","}
}

local function encodeChar(charValue, nested)
    if charValue == 0 then return nested and "" or "❤️" end
    for _, v in pairs(CHARACTER_VALUES) do
        if charValue >= v[1] then
            -- val, currentCase = v[1], v[2]
            -- return currentCase .. encodeChar(charValue - val)
            return v[2] .. encodeChar(charValue - v[1], true)
        end
    end
end

local encoding = {}
local decoding = {}

for i = 0, 255 do
    local c, r = char(i), encodeChar(i)

    encoding[c] = r
    decoding[r] = c
end

return {encoding = encoding, decoding = decoding}
