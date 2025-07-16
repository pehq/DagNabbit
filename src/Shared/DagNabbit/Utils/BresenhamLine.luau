--taken from w3school
--Modified by Pehq to allow touching lines.
local Dag = script:FindFirstAncestor("DagNabbit")
local RectArgs = require(Dag.Utils.RectArgs)

local Bresenham = {}

function Bresenham.MakeLine(...: Rect | (Vector2 & Vector2) | (number & number & number & number))
    print(typeof(...))

    --Handle Args
   local RectVal = RectArgs(...)
	
    local Points = {}

    local m_new = 2 * (RectVal.Max.Y - RectVal.Min.Y)
    local slope_error_new = m_new - (RectVal.Max.X - RectVal.Min.X)

    local y = RectVal.Min.Y
    for x = RectVal.Min.X, RectVal.Max.X + 1 do
        table.insert(Points, Vector2.new(x, y))

        -- Add slope to increment angle formed
		slope_error_new += m_new
		print(slope_error_new)
		
        if slope_error_new >= 0 then
            y += 1
            slope_error_new -= 2 * (RectVal.Max.X - RectVal.Min.X)
        end
    end

    return Points
end

function Bresenham.TouchingLines(...: Rect | (Vector2 & Vector2) | (number & number & number & number))
    local RectVal = RectArgs(...)

    local m = (RectVal.Max.Y - RectVal.Min.Y) / (RectVal.Max.X - RectVal.Min.X) --Slope

    local Points = Bresenham.MakeLine(RectVal)
    local PointsToAdd = {}

    for i = 1, #Points do
        if i == #Points then
            continue
        end
        
        if m < 1 then  --Horizontal slope
            --Check ahead
            if Points[i].Y ~= Points[i + 1].Y then
                table.insert(PointsToAdd, Points[i] + Vector2.yAxis)
            end
        elseif m > 1 then --Vertical slope
            if Points[i].X ~= Points[i + 1].X then
                table.insert(PointsToAdd, Points[i] + Vector2.xAxis)
            end
        end
	end
	print(PointsToAdd)
    
    table.move(PointsToAdd, 1, #PointsToAdd, #Points + 1, Points)

    return Points
end

return Bresenham