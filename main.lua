local http = require("socket.http")
local url = require("socket.url")
local ltn12 = require("ltn12")

local function parseArgs(args)
    local result = {}
    local i = 1

    while i <= #args do
        local argName = args[i]
        local argValue = args[i + 1]

        if argName and argName:sub(1, 1) == "-" then
            argName = argName:sub(2)
            result[argName] = argValue
            i = i + 2
        else
            i = i + 1
        end
    end

    return result
end

local function printHelp()
    print("Usage: lua lirb.lua -url <url> -wl <path> [options]")
    print("  -target url                          : Target URL")
    print("  -wl path                          : Path to wordlist")
    print("Options:")
    print("  -cc int                           : Character count of the response to filter")
    print("  -cookies test=abc;token=xyz       : Add cookies to the requests")
    print("  -headers Authorization Bearer 123 : Add custom headers to the requests. Use this for Authorization tokens")
    print("  -threads int                      : How many requests can be sent in parallel")
    print("  -proxy http://127.0.0.1:8080      : Add proxy")
    print("  -port int                         : Add port")
end

local function makeRequest(target, headers, cookies, port, proxy)
    local request_headers = {}
    if headers then
        for header in headers:gmatch("([^;]+)") do
            local key, value = header:match("([^:]+):%s*(.+)")
            if key and value then
                request_headers[key] = value
            end
        end
    end

    if cookies then
        request_headers["Cookie"] = cookies
    end

    local response = {}
    local _, statusCode, headers, statusText = http.request{
        url = target,
        method = "GET",
        headers = request_headers,
        proxy = proxy,
        port = port,
        sink = ltn12.sink.table(response)
    }

    return statusCode, statusText, headers
end

local function getFullURL(baseURL, wordlistPath)
    local fullURLs = {}

    if baseURL:sub(-1) ~= "/" then
        baseURL = baseURL .. "/"
    end

    local file = io.open(wordlistPath, "r")
    if not file then
        print("Error: Unable to open wordlist file")
        return fullURLs
    end

    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")
        local fullURL = baseURL .. line
        table.insert(fullURLs, fullURL)
    end

    file:close()
    return fullURLs
end

if arg[1] == "--help" then
    printHelp()
else
    local namedArgs = parseArgs(arg)

    local target = namedArgs["target"]
    local wl = namedArgs["wl"]
    local cc = namedArgs["cc"]
    local cookies = namedArgs["cookies"]
    local headers = namedArgs["headers"]
    local threads = namedArgs["threads"]
    local proxy = namedArgs["proxy"]

    if target and wl then
        local parsed_url = url.parse(target)
        local port = parsed_url.port
            
        if port then
            target = target:gsub(":" .. port, "")
        elseif namedArgs["port"] then
            port = namedArgs["port"]
        else
            port = parsed_url.scheme == "https" and 443 or 80
        end

        print("\n=====================================================")
        for argName, argValue in pairs(namedArgs) do
            print("" .. argName .. "\t:\t" .. argValue)
        end
        print("=====================================================\n")

        local fullURLs = getFullURL(target, wl)

        for i, fullURL in ipairs(fullURLs) do
            io.write(string.format("\rProgress: %d / %d", i, #fullURLs))
            io.flush()

            local response = makeRequest(fullURL, headers, cookies, port, proxy)
            io.write(response)
            --[[
            if response and response:match("^HTTP/[%d%.]+ 200 OK") then
                io.write(string.format("\r%s - Response Length: %d\n", fullURL, #response))
            end
            ]]
        end
        print()
    else
        printHelp()
    end
end