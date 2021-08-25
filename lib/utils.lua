local Utils = {}

function Utils.polygonPoints(radius, pointCount, angle_offset)
    angle_offset = angle_offset or 0
    local points = {}
    for i=0, pointCount-1 do
        table.insert(points, radius * math.cos(2 * math.pi * i / pointCount + angle_offset))
        table.insert(points, radius * math.sin(2 * math.pi * i / pointCount + angle_offset))
    end
    return points
end

function Utils.bearingFromPositions(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.atan2(dy, dx)
end

function Utils.tableIsEmpty(t) -- #t only works for numeric keys
    for k,v in pairs(t) do
        if k or v then
            return false
        end
    end
    return true
end

function Utils.tableCountKeys(t)
    local count = 0
    for _,__ in pairs(t) do
        count = count + 1
    end
    return count
end

function Utils.removeItemFromArray(array, item)
    for i,v in ipairs(array) do
        if v == item then
            table.remove(array, i)
            return
        end
    end
end

function Utils.duplicateTable(oldTable)
    local t = {}
    for k,v in pairs(oldTable) do
        t[k] = v
    end
    return t
end

function Utils.toSlabProperties(properties)
    local out = {}
    for k,v in pairs(properties) do
        table.insert(out, {
            ID = k,
            Value = v,
        })
    end
    return out
end

function Utils.fromSlabProperties(properties)
    local out = {}
    for i,v in ipairs(properties) do
        out[v.ID] = v.Value
    end
    return out
end

return Utils