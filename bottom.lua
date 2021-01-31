local byte, char, gsub, gmatch = string.byte, string.char, string.gsub,
                                 string.match
local CHARACTER_VALUES = {
    {200, "🫂"}, {50, "💖"}, {10, "✨"}, {5, "🥺"}, {1, ","}
}

local SECTION_SEPERATOR = "👉👈"

local function getCase(charValue)
    for _, v in pairs(CHARACTER_VALUES) do
        if charValue >= v[1] then return v[1], v[2] end
    end
end

local function encodeChar(charValue)
    if charValue == 0 then return "" end
    local val, currentCase = getCase(charValue)
    return currentCase .. encodeChar(charValue - val)
end

local function encode(value)
    local result = gsub(value, ".", function(c)
        return encodeChar(byte(c)) .. SECTION_SEPERATOR
    end)

    return result
end

local function getCaseFromEmoji(em)
    for _, v in next, CHARACTER_VALUES do
        if em == v[2] then return v[1], v[2] end
    end
end

local function decode(value)
    local result = gsub(value, "(.-)" .. SECTION_SEPERATOR, function(c)
        -- https://stackoverflow.com/questions/13235091/extract-the-first-letter-of-a-utf-8-string-with-lua
        local code = 0
        gsub(c, "[%z\1-\127\194-\244][\128-\191]*", function(char)
            local value = getCaseFromEmoji(char)
            assert(value, "Invalid bottom text: '" .. char .. "'")
            code = code + value
        end)
        return char(code)
    end)
    return result
end

--[[ 
    local e = encode("がんばれ")
    local io = require "io"
    local file = io.open("encode.txt", "wb")
    file:write(e)
    file:close()

    local file = io.open("decode.txt", "wb")
    file:write(decode(e))
    file:close()
]]

return {encode = encode, decode = decode}
