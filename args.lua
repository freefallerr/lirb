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

return {
    parseArgs = parseArgs,
    processArgs = processArgs,
    printHelp = printHelp,
}