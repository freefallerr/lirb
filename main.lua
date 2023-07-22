local args = require("args")
local http_request = require("http_request")
local url = require("socket.url")
local utils = require("utils")

local function run_requests(params)
    local full_urls = utils.get_full_url(params.target, params.wl)
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

    if named_args.target and named_args.wl then
        local parsed_url = url.parse(named_args.target)
        named_args.port = parsed_url.port

        if named_args.port then
            named_args.target = named_args.target:gsub(":" .. named_args.port, "")
        elseif named_args["port"] or named_args["p"] then
            named_args.port = named_args["port"] or named_args["p"]
        else
            named_args.port = parsed_url.scheme == "https" and 443 or 80
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

        local valid_urls = run_requests(named_args)

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