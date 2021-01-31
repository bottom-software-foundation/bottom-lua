local byte, char, gsub, gmatch = string.byte, string.char, string.gsub,
                                 string.gmatch

-- Replace GETGLOBAL with GETUPVAL instructions, the latter doesn't involve indexing the global table
local pairs, assert = pairs, assert

local CHARACTER_VALUES = {
    {1, ","}, {5, "🥺"}, {10, "✨"}, {50, "💖"}, {200, "🫂"}
}

-- Next variable is calculated when this module is loaded
-- {[1] = ",", [5] = "🥺", ...}
local CHARACTER_VALUES_LOOKUPIFIED =
    (function(CHARACTER_VALUES) -- Having a local like this saves a GETUPVAL instruction
        local r = {}
        for _, v in pairs(CHARACTER_VALUES) do r[v[2]] = v[1] end
        return r
    end)(CHARACTER_VALUES)

local function encodeChar(charValue)
    if charValue == 0 then return "" end
    local val, currentCase
    for _, v in pairs(CHARACTER_VALUES) do
        if charValue >= v[1] then val, currentCase = v[1], v[2] end
    end
    return currentCase .. encodeChar(charValue - val)
end

local function encode(value)
    local result = gsub(value, ".", function(c)
        return encodeChar(byte(c)) .. "👉👈"
    end)

    return result
end

local function decode(value)
    local result = gsub(value, "(.-)👉👈", function(c)
        -- https://stackoverflow.com/questions/13235091/extract-the-first-letter-of-a-utf-8-string-with-lua
        local code = 0
        for char in gmatch(c, "[%z\1-\127\194-\244][\128-\191]*") do
            local value = CHARACTER_VALUES_LOOKUPIFIED[char]
            assert(value, "Invalid bottom text: '" .. char .. "'")
            code = code + value
        end
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
