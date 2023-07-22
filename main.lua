local http = require("socket.http")
local ltn12 = require("ltn12")

-- Function to parse named arguments
local function parseArgs(args)
    local result = {}
    local i = 1

    while i <= #args do
        local argName = args[i]
        local argValue = args[i + 1]

        if argName and argName:sub(1, 1) == "-" then
            argName = argName:sub(2) -- Remove the leading '-'
            result[argName] = argValue
            i = i + 2
        else
            i = i + 1
        end
    end

    return result
end

-- Function to print the help message
local function printHelp()
    print("Usage: lua lirb.lua -url <url> -wl <path> [options]")
    print("  -url url                          : Target URL")
    print("  -wl path                          : Path to wordlist")
    print("Options:")
    print("  -cc int                           : Character count of the response to filter")
    print("  -cookies test=abc;token=xyz       : Add cookies to the requests")
    print("  -headers Authorization Bearer 123 : Add custom headers to the requests. Use this for Authorization tokens")
    print("  -threads int                      : How many requests can be sent in parallel")
    print("  -proxy http://127.0.0.1           : Add proxy")
end

local function makeRequest(url, headers, cookies, proxy)
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
        url = url,
        method = "GET",
        headers = request_headers,
        sink = ltn12.sink.table(response_body),
        proxy = proxy
    }

    if response_code == 200 then
        return table.concat(response_body)
    else
        return nil
    end
end

local function getFullURL(baseURL, wordlistPath)
    local fullURLs = {}
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

    -- Access named arguments (if present)
    local url = namedArgs["url"]
    local wl = namedArgs["wl"]
    local cc = namedArgs["cc"]
    local cookies = namedArgs["cookies"]
    local headers = namedArgs["headers"]
    local threads = namedArgs["threads"]
    local proxy = namedArgs["proxy"]

    if url and wl then
        print("URL:", url)
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

        -- Get full URLs from the wordlist
        local fullURLs = getFullURL(url, wl)

        -- Make requests for each full URL
        for _, fullURL in ipairs(fullURLs) do
            print("Making request to:", fullURL)
            local response = makeRequest(fullURL, headers, cookies, proxy)
            if response then
                print("Response:")
                print(response:sub(1, 500)) -- Print the first 500 characters of the response
            else
                print("Failed to make the request.")
            end
        end
    else
        printHelp()
    end

end