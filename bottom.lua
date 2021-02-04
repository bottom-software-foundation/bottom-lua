local byte, char, gsub, gmatch = string.byte, string.char, string.gsub,
                                 string.gmatch

local pairs, error = pairs, error

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

local function encode(value)
    local result = gsub(value, ".", function(c)
        return encodeChar(byte(c)) .. "👉👈"
    end)

    return result
end

local CHARACTER_VALUES_LOOKUPIFIED = {
    ["🫂"] = 200,
    ["💖"] = 50,
    ["✨"] = 10,
    ["🥺"] = 5,
    [","] = 1,
    ["❤"] = 0
}

local concat = table.concat
local function fmt(chr) return concat({byte(chr, 1, -1)}, ", ") end

local function decode(value)
    local result = gsub(value, "(.-)👉👈", function(c)
        -- https://stackoverflow.com/questions/13235091/extract-the-first-letter-of-a-utf-8-string-with-lua
        local code = 0
        for char in gmatch(gsub(c, "❤️", "❤"),
                           "[%z\1-\127\194-\244][\128-\191]*") do
            code = code + (CHARACTER_VALUES_LOOKUPIFIED[char] or
                       error("No such bottom character `" .. char .. "`<" ..
                                 fmt(char) .. "> in `" .. fmt(c) .. "`"))
        end

        return char(code)
    end)

    return result
end

return {encode = encode, decode = decode}
