local function getFullURL(baseURL, wordlistPath)
    local fullURLs = {}

    if baseURL:sub(-1) ~= "/" then
        baseURL = baseURL .. "/"
    end

    local file = io.open(wordlistPath, "r")
    if not file then
        print("Error: Unable to open wordlist file")
        return fullURLs
    end

    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")
        local fullURL = baseURL .. line
        table.insert(fullURLs, fullURL)
    end

    file:close()
    return fullURLs
end

local function table_copy(t)
    local copy = {}
    for key, value in pairs(t) do
        copy[key] = value
    end
    return copy
end

return {
    getFullURL = getFullURL,
    table_copy = table_copy,
}