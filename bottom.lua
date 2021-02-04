--[[
    local byte, char, gsub, gmatch = string.byte, string.char, string.gsub,
                                 string.gmatch

    local pairs, error = pairs, error

    Encoding<1>:
        Result: PASS
        Ran 10000 iterations in 85ms
    Encoding<12>:
        Result: PASS
        Ran 10000 iterations in 46ms
    Encoding<1>:
        Result: PASS
        Ran 10000 iterations in 40ms

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

    Decoding<12>:
        Result: PASS
        Ran 10000 iterations in 7ms
    Decoding<1>:
        Result: PASS
        Ran 10000 iterations in 7ms
    Decoding<4>:
        Result: PASS
        Ran 10000 iterations in 12ms
    Decoding<1>:
        Result: PASS
        Ran 10000 iterations in 10ms

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
]] --
local gsub = string.gsub
local byte = string.byte
local concat = table.concat

local map = require("map")
encoding, decoding = map.encoding, map.decoding

--[[
    Encoding<1>:
        Result: PASS
        Ran 10000 iterations in 11ms
    Encoding<12>:
        Result: PASS
        Ran 10000 iterations in 11ms
    Encoding<1>:
        Result: PASS
        Ran 10000 iterations in 11ms
]]
local function encode(value)
    local result = gsub(value, ".",
                        function(c) return encoding[c] .. "👉👈" end)

    return result
end

local function fmt(chr) return concat({byte(chr, 1, -1)}, ", ") end

--[[
    Decoding<12>:
        Result: PASS
        Ran 10000 iterations in 7ms
    Decoding<1>:
        Result: PASS
        Ran 10000 iterations in 9ms
    Decoding<1>:
        Result: PASS
        Ran 10000 iterations in 8ms
]]
local function decode(value)
    local result = gsub(value, "(.-)👉👈", function(c)
        return (decoding[c] or error("Invalid bottom `" .. fmt(c) .. "`"))
    end)

    return result
end

return {encode = encode, decode = decode}
