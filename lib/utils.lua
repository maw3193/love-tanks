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

return Utils