local defaults = {
    threads = 1,
    status_codes = {200, 301, 302, 401},
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
    port = 80,
}

local function parse_args(args)
    local result = {}
    local i = 1

    while i <= #args do
        local arg_name = args[i]

        if arg_name and arg_name:sub(1, 2) == "--" then
            arg_name = arg_name:sub(3)

            if arg_name == "status-codes" then
                -- Split comma-separated status codes into a table
                local codes = {}
                local status_codes_str = args[i + 1]
                for code in status_codes_str:gmatch("%S+") do
                    table.insert(codes, code)
                end
                result[arg_name] = codes
            else
                result[arg_name] = args[i + 1]
            end

            i = i + 2
        elseif arg_name and arg_name:sub(1, 1) == "-" then
            arg_name = arg_name:sub(2)

            if arg_name == "sc" then
                local codes = {}
                local status_codes_str = args[i + 1]
                for code in status_codes_str:gmatch("%S+") do
                    table.insert(codes, code)
                end
                result["status-codes"] = codes
            else
                result[arg_name] = args[i + 1]
            end

            i = i + 2
        else
            i = i + 1
        end
    end

    return result
end

local function process_args(args)
    local named_args = parse_args(args)

    for key, default_value in pairs(defaults) do
        named_args[key] = named_args[key] or default_value
    end

    return named_args
end

local function print_help()
    print("Usage: lua lirb.lua --target <url> --wordlist <path> [options]")
    print("  --target or -t url                        : Target URL")
    print("  --wordlist or -w path                     : Path to wordlist")
    print("Options:")
    print("  --character-count or -cc int              : Character count of the response to filter")
    print("  --cookies or -c test=abc;token=xyz        : Add cookies to the requests")
    print("  --headers or -h Authorization Bearer 123  : Add custom headers to the requests. Use this for Authorization tokens")
    print("  --threads or -T int                       : How many requests can be sent in parallel")
    print("  --proxy or -P http://127.0.0.1:8080       : Add proxy")
    print("  --port or -p int                          : Add port")
    print("  --status_codes or -sc int,int,...         : Comma-separated list of status codes to whitelist")
    print("  --user_agent or -ua string                : Custom user-agent to use for requests")
end

return {
    parse_args = parse_args,
    process_args = process_args,
    print_help = print_help,
}