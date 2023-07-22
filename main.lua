local args = require("args")
local http_request = require("http_request")
local url = require("socket.url")
local utils = require("utils")

local function run_requests(params)
    local full_urls = utils.get_full_url(params.target, params.wordlist)
    local valid_urls = {}

    for i, full_url in ipairs(full_urls) do
        io.write(string.format("\rProgress: %d / %d", i, #full_urls))
        io.flush()

        local request_params = utils.table_copy(params)
        request_params.target = full_url

        http_request.process_request(request_params, valid_urls)
    end

    return valid_urls
end

local function main()
    local named_args = args.process_args(arg)

    local params = {
        target = named_args["target"] or named_args["t"],
        wordlist = named_args["wordlist"] or named_args["wl"],
        character_count = named_args["character-count"] or named_args["cc"],
        cookies = named_args["cookies"] or named_args["c"],
        headers = named_args["headers"] or named_args["h"],
        threads = named_args["threads"] or named_args["T"],
        proxy = named_args["proxy"] or named_args["P"],
        status_codes = named_args["status-codes"] or named_args["sc"],
        user_agent = named_args["user-agent"] or named_args["ua"]
    }

    if params.target and params.wordlist then
        local parsed_url = url.parse(params.target)
        params.port = parsed_url.port

        if params.port then
            params.target = params.target:gsub(":" .. params.port, "")
        elseif named_args["port"] or named_args["p"] then
            params.port = named_args["port"] or named_args["p"]
        else
            params.port = parsed_url.scheme == "https" and 443 or 80
        end

        local max_arg_length = 0
        for arg_name, _ in pairs(named_args) do
            if #arg_name > max_arg_length then
                max_arg_length = #arg_name
            end
        end

        print("\n=====================================================")
        for arg_name, arg_value in pairs(named_args) do
            local padding = string.rep(" ", max_arg_length - #arg_name + 2)
            print(string.format("  %s:%s%s", arg_name, padding, tostring(arg_value)))
        end
        print("=====================================================\n")

        local valid_urls = run_requests(params)

        print("\nValid URLs:")
        for _, url_info in ipairs(valid_urls) do
            print(url_info.url)
        end

        print("\n=====================================================")
        print("Finished")
        print("=====================================================\n")
    else
        args.print_help()
    end
end

if arg[1] == "--help" then
    args.print_help()
else
    main()
end