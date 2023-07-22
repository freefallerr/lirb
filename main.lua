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
            argName = argName:sub(3)
            result[argName] = argValue
            i = i + 2
        elseif argName and argName:sub(1, 1) == "-" then
            argName = argName:sub(2)
            result[argName] = argValue
            i = i + 2
        else
            i = i + 1
        end
    end

    return result
end

local function processArgs(args)
    local defaultArgs = {
        threads = 10,
        port = 80,
        status_codes = 200
    }

    local namedArgs = parseArgs(args)

    for key, value in pairs(defaultArgs) do
        namedArgs[key] = namedArgs[key] or value
    end

    return namedArgs
end

local function printHelp()
    print("Usage: lua lirb.lua -url <url> -wl <path> [options]")
    print("  --target or -t url                        : Target URL")
    print("  --wordlist or -w path                     : Path to wordlist")
    print("Options:")
    print("  --character-count or -cc int              : Character count of the response to filter")
    print("  --cookies or -c test=abc;token=xyz        : Add cookies to the requests")
    print("  --headers or -h Authorization Bearer 123  : Add custom headers to the requests. Use this for Authorization tokens")
    print("  --threads or -T int                       : How many requests can be sent in parallel")
    print("  --proxy or -P http://127.0.0.1:8080       : Add proxy")
    print("  --port or -p int                          : Add port")
    print("  --status-codes or -sc int,int,...         : Comma-separated list of status codes to whitelist")
    print("  --user-agent or -ua string                : Custom user-agent to use for requests")
end

local function makeRequest(params)
    local request_headers = {}

    if params.headers then
        for header in params.headers:gmatch("([^;]+)") do
            local key, value = header:match("([^:]+):%s*(.+)")
            if key and value then
                request_headers[key] = value
            end
        end
    end

    if params.cookies then
        request_headers["Cookie"] = params.cookies
    end

    if params.user_agent then
        request_headers["User-Agent"] = params.user_agent
    end

    local response_body = {}
    local _, status_code, response_headers, status_text = http.request{
        url = params.target,
        method = "GET",
        headers = request_headers,
        proxy = params.proxy,
        port = params.port,
        sink = ltn12.sink.table(response_body)
    }

    local response = table.concat(response_body)

    return response, status_code, status_text
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

local function checkStatusCode(status_code, status_codes)
    if not status_codes then
        status_codes = {200}
    end

    for _, code in ipairs(status_codes) do
        if tonumber(code) == tonumber(status_code) then
            return true
        end
    end

    return false
end

local function processRequest(params, valid_urls)
    local response, status_code, status_text = makeRequest(params)
    if checkStatusCode(status_code, params.status_codes) then
        if not params.character_count or #response ~= params.character_count then
            io.write(string.format("\r%s - Status Code: %s, Response Length: %d\n", params.target, status_code, #response))
            table.insert(valid_urls, {url = params.target, status = status_code, response = response})
        end
    end
end

local function runRequests(params)
    local full_urls = getFullURL(params.target, params.wl)
    
    local valid_urls = {}

    for i, full_url in ipairs(full_urls) do
        io.write(string.format("\rProgress: %d / %d", i, #full_urls))
        io.flush()
        params.target = full_url
        processRequest(params, valid_urls)
    end

    return valid_urls
end


local function main()
    local namedArgs = processArgs(arg)

    local params = {
        target = namedArgs["target"] or namedArgs["t"],
        wl = namedArgs["wordlist"] or namedArgs["wl"],
        character_count = namedArgs["character-count"] or namedArgs["cc"],
        cookies = namedArgs["cookies"] or namedArgs["c"],
        headers = namedArgs["headers"] or namedArgs["h"],
        threads = namedArgs["threads"] or namedArgs["T"],
        proxy = namedArgs["proxy"] or namedArgs["P"],
        status_codes = namedArgs["status-codes"] or namedArgs["sc"],
        user_agent = namedArgs["user-agent"] or namedArgs["ua"]
    }

    if params.target and params.wl then
        local parsed_url = url.parse(params.target)
        params.port = parsed_url.port
            
        if params.port then
            params.target = params.target:gsub(":" .. params.port, "")
        elseif namedArgs["port"] or namedArgs["p"] then
            params.port = namedArgs["port"] or namedArgs["p"]
        else
            params.port = parsed_url.scheme == "https" and 443 or 80
        end

        print("\n=====================================================")
        for argName, argValue in pairs(namedArgs) do
            print(string.format("  %s:\t%s", argName, argValue))
        end
        print("=====================================================\n")

        local valid_urls = runRequests(params)

        print("\nValid URLs:")
        for _, url_info in ipairs(valid_urls) do
            print(url_info.url)
        end

        print("\n=====================================================")
        print("Finished")
        print("=====================================================\n")
    else
        printHelp()
    end
end

if arg[1] == "--help" then
    printHelp()
else
    main()
end