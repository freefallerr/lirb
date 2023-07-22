local http = require("socket.http")
local ltn12 = require("ltn12")

local function make_request(params)
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

    local response = {
        body = table.concat(response_body),
        code = status_code,
        status = status_text
    }

    return response
end

local function check_status_code(status_code, status_codes)
    for _, code in ipairs(status_codes) do
        if tonumber(code) == tonumber(status_code) then
            return true
        end
    end

    return false
end

local function process_request(params, valid_urls)
    local response = make_request(params)
    print(response.code)
    if check_status_code(response.code, params.status_codes) then
        if not params.character_count or #response.body ~= params.character_count then
            io.write(string.format("\r%s - Status Code: %s, Response Length: %d\n", params.target, response.code, #response.body))
            table.insert(valid_urls, {url = params.target, status = response.code, response = response.body})
        end
    end
end

return {
    make_request = make_request,
    check_status_code = check_status_code,
    process_request = process_request,
}