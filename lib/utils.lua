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

return Utils