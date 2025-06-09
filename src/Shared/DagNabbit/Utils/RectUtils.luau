local RectUtils = {}

--Check if Rect a overlaps Rect b.
function RectUtils.Overlaps(a:Rect, b:Rect)
	--No horizontal overlap
	if a.Min.X >= b.Max.X or b.Min.X >= a.Min.X then
		return false
	end
	
	if a.Min.Y >= b.Max.Y or b.Min.Y >= a.Max.Y then
		return false
	end
	
	return true
end

--https://gist.github.com/Daniel-Hug/d7984d82b58d6d2679a087d896ca3d2b
function RectUtils.Touching(a:Rect, b:Rect)
	if a.Min.X > b.Max.X or b.Min.X > a.Max.X then
		return false
	end

	if a.Min.Y > b.Max.Y or b.Min.Y > a.Max.Y then
		return false
	end

	return true
end

--Check if rect a is covering rect b
function RectUtils.Covering(a:Rect, b:Rect)
	if a.Min.X <= b.Min.X and a.Min.Y <= b.Min.Y and a.Max.X >= b.Max.X and a.Max.Y >= b.Max.Y then
		return true
	end
	
	return false
end

return RectUtils