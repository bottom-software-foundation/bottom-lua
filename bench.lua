local bottom = require("bottom")
local encode, decode = bottom.encode, bottom.decode

local tests
do
    local json, io = require("json"), require("io")

    local file = io.open("testing.json", "rb")
    if not file then error("testing.json not detected") end
    tests = json.decode(file:read("*a"))
    file:close()
end

local iterations = 100000

local sformat = string.format
local function format(t) return sformat("%dns", t / iterations * 1e9) end

local clock = os.clock
for i, o in pairs(tests.encode) do
    print("Encoding<" .. #i .. ">:")
    if encode(i) == o then
        print("\tResult: PASS")

        local start = clock()
        for i = 1, iterations do encode(i) end

        print("\tEach iteration of " .. iterations .. " iterations took " ..
                  format(clock() - start))
    else
        print("\tResult: FAILURE")
    end
end

print()

for i, o in pairs(tests.decode) do
    print("Decoding<" .. #o .. ">:")
    if decode(i) == o then
        print("\tResult: PASS")

        local start = clock()
        for i = 1, iterations do decode(i) end

        print("\tEach iteration of " .. iterations .. " iterations took " ..
                  format(clock() - start))
    else
        print("\tResult: FAILURE")
    end
end
