local ArgsToVector2 = {
	["number"] = function(args:number)
		return Vector2.new(args, args)
	end,
	["Vector2"] = function(args:Vector2)
		return args
	end,
	["Vector2int16"] = function(args:Vector2int16) --If you encounter a bug while using Vector2int16s then contact me.
		return args
	end,
	["Vector3"] = function(args:Vector3)
		return Vector2.new(args.X, args.Y) --Z is simply excluded
	end,
	["Vector3int16"] = function(args:Vector3int16)
		return Vector2int16.new(args.X, args.Y)
	end,
	["nil"] = function()
		return Vector2.zero
	end,
	["table"] = function(args:{})
			
		if args[1] ~= nil and args[2] ~= nil then
			return Vector2.new(args[1], args[2])
		elseif args[1] ~= nil and args[2] == nil then
			return Vector2.new(args[1], args[1])
		else
			return Vector2.zero
		end
	end,
	["boolean"] = function(args:boolean)
		print(args)
		local Val = args and 1 or 0
		return Vector2.new(Val, Val)
	end,
}

return function(...)
    if ... == nil then
        return Vector2.zero
    end
    local args = typeof(...) == "table" or #{...} <= 1 and ... or {...}
	args = ArgsToVector2[typeof(args)](args)

    return args
end