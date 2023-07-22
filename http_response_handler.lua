local function has_error_content(body)
    local error_keywords = { "404", "failed to connect", "file not found" }

    for _, keyword in ipairs(error_keywords) do
        if body:lower():find(keyword) then
            return true
        end
    end

    return false
end

return {
    has_error_content = has_error_content,
}