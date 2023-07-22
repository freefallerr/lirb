local args = require("args")
local http_request = require("http_request")
local url = require("socket.url")
local utils = require("utils")

local function runRequests(params)
    local full_urls = utils.getFullURL(params.target, params.wl)
    local valid_urls = {}

    for i, full_url in ipairs(full_urls) do
        io.write(string.format("\rProgress: %d / %d", i, #full_urls))
        io.flush()

        local request_params = utils.table_copy(params)
        request_params.target = full_url

        http_request.processRequest(request_params, valid_urls)
    end

    return valid_urls
end


local function main()
    local namedArgs = args.processArgs(arg)

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

        local maxArgLength = 0
        for argName, _ in pairs(namedArgs) do
            if #argName > maxArgLength then
                maxArgLength = #argName
            end
        end

        print("\n=====================================================")
        for argName, argValue in pairs(namedArgs) do
            local padding = string.rep(" ", maxArgLength - #argName + 2)
            print(string.format("  %s:%s%s", argName, padding, argValue))
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
        args.printHelp()
    end
end

if arg[1] == "--help" then
    args.printHelp()
else
    main()
end
