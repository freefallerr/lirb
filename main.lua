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
    print("  -proxy http://127.0.0.1           : Add proxy")
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

    local response_body = {}
    local response, response_code, response_headers, response_status = http.request{
        url = target,
        method = "GET",
        headers = request_headers,
        sink = ltn12.sink.table(response_body),
        proxy = proxy,
        port = port
    }

    if response_code == 200 then
        return table.concat(response_body)
    else
        print("Error:", response_code, response_status)
    end
end

local function getFullURL(baseURL, wordlistPath)
    local fullURLs = {}

    if baseURL:sub(-1) ~= "/" then
        baseURL = baseURL .. "/"
    end

    for line in io.lines(wordlistPath) do
        local fullURL = baseURL .. line
        table.insert(fullURLs, fullURL)
    end
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
        print("URL:", target)
        print("Wordlist:", wl)

        if cc then
            print("Character Count:", cc)
        end

        if cookies then
            print("Cookies:", cookies)
        end

        if headers then
            print("Headers:", headers)
        end

        if threads then
            print("Threads:", threads)
        end

        if proxy then
            print("Proxy:", proxy)
        end

        local parsed_url = url.parse(target)
        local port = parsed_url.port
            
        if port then
            target = target:gsub(":" .. port, "")
        elseif namedArgs["port"] then
            port = namedArgs["port"]
        else
            port = parsed_url.scheme == "https" and 443 or 80
        end

        if port then
            print("Port:", port)
        end

        local fullURLs = getFullURL(target, wl)

        for _, fullURL in ipairs(fullURLs) do
            print("Making request to:", fullURL)
            local response = makeRequest(fullURL, headers, cookies, port, proxy)
            if response then
                print("Response for", fullURL, ":", response:sub(1,100))
            end
        end
    else
        printHelp()
    end

end