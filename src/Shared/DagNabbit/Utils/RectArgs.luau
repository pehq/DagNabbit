--Pehq
return function(...)
	local x = nil
	if typeof(...) == "nil" then
		x = Rect.new(0,0,0,0)
	end
	x = typeof(...) == "Rect" and ... or  Rect.new(...)

	return x
end