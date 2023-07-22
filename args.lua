local function parse_args(args)
    local result = {}
    local i = 1

    while i <= #args do
        local arg_name = args[i]
        local arg_value = args[i + 1]

        if arg_name and arg_name:sub(1, 2) == "--" then
            arg_name = arg_name:sub(3)
            result[arg_name] = arg_value
            i = i + 2
        elseif arg_name and arg_name:sub(1, 1) == "-" then
            arg_name = arg_name:sub(2)
            result[arg_name] = arg_value
            i = i + 2
        else
            i = i + 1
        end
    end

    return result
end

local function process_args(args)
    local default_args = {
        threads = 10,
        port = 80,
        status_codes = 200, 301, 302, 401
    }

    local named_args = parse_args(args)

    for key, value in pairs(default_args) do
        named_args[key] = named_args[key] or value
        print(named_args[key])
    end

    return named_args
end

local function print_help()
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
    parse_args = parse_args,
    process_args = process_args,
    print_help = print_help,
}