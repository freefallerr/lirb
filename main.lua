local http = require("socket.http")
local url = require("socket.url")
local ltn12 = require("ltn12")

local function parseArgs(args)
    local result = {}
    local i = 1

    while i <= #args do
        local argName = args[i]
        local argValue = args[i + 1]

        if argName and argName:sub(1, 2) == "--" then
            argName = argName:sub(3) -- Remove the leading '--' for long arguments
            result[argName] = argValue
            i = i + 2
        elseif argName and argName:sub(1, 1) == "-" then
            argName = argName:sub(2) -- Remove the leading '-' for short arguments
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
    print("  --target or -t url                        : Target URL")
    print("  --wordlist or -w path                     : Path to wordlist")
    print("Options:")
    print("  --charactercount or -cc int               : Character count of the response to filter")
    print("  --cookies or -c test=abc;token=xyz        : Add cookies to the requests")
    print("  --headers or -h Authorization Bearer 123 : Add custom headers to the requests. Use this for Authorization tokens")
    print("  --threads or -T int                       : How many requests can be sent in parallel")
    print("  --proxy or -P http://127.0.0.1:8080       : Add proxy")
    print("  --port or -p int                          : Add port")
    print("  --statuscodes or -sc int,int,...          : Comma-separated list of status codes to whitelist")
    print("  --user-agent or -ua string                : Custom user-agent to use for requests")
end

local function makeRequest(target, headers, cookies, port, proxy, user_agent)
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

    if user_agent then
        request_headers["User-Agent"] = user_agent
    end

    local response_body = {}
    local _, statusCode, response_headers, statusText = http.request{
        url = target,
        method = "GET",
        headers = request_headers,
        proxy = proxy,
        port = port,
        sink = ltn12.sink.table(response_body)
    }

    local response = table.concat(response_body)

    return response, statusCode, statusText
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

local function checkStatusCode(statusCode, statuscodes)
    if not statuscodes then
        statuscodes = {200}
    end

    for _, code in ipairs(statuscodes) do
        if tonumber(code) == tonumber(statusCode) then
            return true
        end
    end

    return false
end

local function processRequest(target, headers, cookies, port, proxy, user_agent, statuscodes)
    local response, statusCode, statusText = makeRequest(target, headers, cookies, port, proxy, user_agent)
    if checkStatusCode(statusCode, statuscodes) then
        io.write(string.format("\r%s - Status Code: %s, Response Length: %d\n", target, statusCode, #response))
    end
end

local function runRequests(baseURL, wordlistPath, headers, cookies, port, proxy, user_agent, statuscodes)
    local fullURLs = getFullURL(baseURL, wordlistPath)

    print("\n=====================================================")
    for argName, argValue in pairs(namedArgs) do
        print("" .. argName .. "\t:\t" .. argValue)
    end
    print("=====================================================\n")

    for i, fullURL in ipairs(fullURLs) do
        io.write(string.format("\rProgress: %d / %d", i, #fullURLs))
        io.flush()
        processRequest(fullURL, headers, cookies, port, proxy, user_agent, statuscodes)
    end

    print("\n=====================================================")
    print("Finished")
    print("=====================================================\n")
end

local function main()
    local namedArgs = parseArgs(arg)

    local target = namedArgs["target"] or namedArgs["t"]
    local wl = namedArgs["wordlist"] or namedArgs["wl"]
    local cc = namedArgs["charactercount"] or namedArgs["cc"]
    local cookies = namedArgs["cookies"] or namedArgs["c"]
    local headers = namedArgs["headers"] or namedArgs["h"]
    local threads = namedArgs["threads"] or namedArgs["T"]
    local proxy = namedArgs["proxy"] or namedArgs["P"]
    local statuscodes = namedArgs["statuscodes"] or namedArgs["sc"]
    local user_agent = namedArgs["user-agent"] or namedArgs["ua"]

    if target and wl then
        local parsed_url = url.parse(target)
        local port = parsed_url.port
            
        if port then
            target = target:gsub(":" .. port, "")
        elseif namedArgs["port"] or namedArgs["p"] then
            port = namedArgs["port"] or namedArgs["p"]
        else
            port = parsed_url.scheme == "https" and 443 or 80
        end

        runRequests(target, wl, headers, cookies, port, proxy, user_agent, statuscodes)
    else
        printHelp()
    end
end

if arg[1] == "--help" then
    printHelp()
else
    main()
end
