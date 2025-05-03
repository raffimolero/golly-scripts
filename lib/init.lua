g = golly()
gp = require "gplus"

U = table.unpack
push = table.insert

---immediately terminates a golly script with a message
---@param msg any
function panic(msg)
    msg = stringify(msg)
    if #msg > 80 then
        msg = string.sub(msg, 1, 256) .. '...'
    end
    msg = 'PANIC: ' .. msg
    g.setclipstr(msg)
    g.error(msg)
    g.exit(msg)
end

---converts any lua value into a string
---@param value any
---@return string
function stringify(value)
    local function stringifyTable(tbl)
        local result = "{"
        for key, val in pairs(tbl) do
            result = result .. "[" .. stringify(key) .. "] = " .. stringify(val) .. ", "
        end
        return result .. "}"
    end

    if type(value) == "table" then
        return stringifyTable(value)
    elseif type(value) == "string" then
        return "\"" .. value .. "\""
    elseif type(value) == "boolean" then
        return value and "true" or "false"
    elseif type(value) == "number" then
        return tostring(value)
    elseif value == nil then
        return "nil"
    else
        return "\"[unsupported value type: " .. type(value) .. "]\""
    end
end

---@generic T
---@param x T
---@return T
function identity(x)
    return x
end

---@generic T
---@param t T[]
---@param f fun(val:T): boolean
---@return table
function map(t, f)
    local out = {}
    for k, v in pairs(t) do
        out[k] = f(v)
    end
    return out
end

---@generic T
---@param t T[]
---@param f? fun(val:T): boolean
---@return boolean
function none(t, f)
    return not any(t, f)
end

---@generic T
---@param t T[]
---@param f? fun(val:T): boolean
---@return boolean
function any(t, f)
    f = f or identity
    for _, v in pairs(t) do
        if f(v) then
            return true
        end
    end
    return false
end

---@generic T
---@param t T[]
---@param f? fun(val:T): boolean
---@return boolean
function all(t, f)
    f = f or identity
    for _, v in pairs(t) do
        if not f(v) then
            return false
        end
    end
    return true
end

---@generic T
---@param c boolean
---@param t T
---@param f T
---@return T
function cond(c, t, f)
    if c then
        return t
    else
        return f
    end
end

---@param ... any[]
---@return any[][]
function zip(...)
    local result = {}
    local args = { ... }
    local min_length = math.huge

    -- Find the minimum length among the input tables
    for _, t in ipairs(args) do
        min_length = math.min(min_length, #t)
    end

    -- Combine elements from the input tables into tuples
    for i = 1, min_length do
        local tuple = {}
        for _, t in ipairs(args) do
            table.insert(tuple, t[i])
        end
        table.insert(result, tuple)
    end

    return result
end

---creates a table containing <item> repeated <count> times
---@generic T
---@param item T
---@param count integer
---@return T[]
function rep(item, count)
    local out = {}
    for i = 1, count do
        table.insert(out, item)
    end
    return out
end

---deep copies a value
---@generic T
---@param original T
---@return T
function clone(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = clone(value)
        else
            copy[key] = value
        end
    end
    return copy
end

---@param ... any[]
---@return any[]
function concat(...)
    local result = {}
    local tables = { ... }

    for _, t in ipairs(tables) do
        for _, v in ipairs(t) do
            table.insert(result, v)
        end
    end

    return result
end

---@param item any[]
---@return any[]
function flatten_one(item)
    return concat(U(item))
end

---@param item any[]
---@param result? any[]
---@return any[]
function flatten_deep(item, result)
    local result = result or {}
    if type(item) == 'table' then
        for k, v in pairs(item) do
            flatten_deep(v, result)
        end
    else
        result[#result + 1] = item
    end
    return result
end

---deep equality
---@param t1 any
---@param t2 any
---@return boolean
function eq(t1, t2)
    -- Check if both are not tables
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return t1 == t2
    end

    -- Check if they have the same set of keys
    local keys1, keys2 = {}, {}
    for k in pairs(t1) do keys1[k] = true end
    for k in pairs(t2) do keys2[k] = true end
    for k in pairs(keys1) do
        if not keys2[k] then return false end
    end
    for k in pairs(keys2) do
        if not keys1[k] then return false end
    end

    -- Recursively compare all values
    for k, v in pairs(t1) do
        if not eq(v, t2[k]) then
            return false
        end
    end

    return true
end

function find(t, f)
    for i, v in ipairs(t) do
        if f(v) then
            return i, v
        end
    end
    return nil, nil
end
