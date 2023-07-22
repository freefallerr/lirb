local function get_full_url(base_url, wordlist_path)
    local full_urls = {}

    if base_url:sub(-1) ~= "/" then
        base_url = base_url .. "/"
    end

    local file = io.open(wordlist_path, "r")
    if not file then
        print("Error: Unable to open wordlist file")
        return full_urls
    end

    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")
        local full_url = base_url .. line
        table.insert(full_urls, full_url)
    end

    file:close()
    return full_urls
end

local function table_copy(t)
    local copy = {}
    for key, value in pairs(t) do
        copy[key] = value
    end
    return copy
end

local function format_value(value)
    if type(value) == "table" then
        return table.concat(value, ", ")
    else
        return tostring(value)
    end
end

return {
    get_full_url = get_full_url,
    table_copy = table_copy,
    format_value = format_value,
}