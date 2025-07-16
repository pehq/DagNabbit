--[=[
	@class RectList

	This is my first class.
]=]

local Dag = script.Parent

local DeepCopy = require(Dag.Utils.DeepCopy)
local RectUtils = require(Dag.Utils.RectUtils)
local RectValMod = require(script.RectVal)

local RectList = {}
RectList.__index = RectList

function RectList.new()
	local self = setmetatable({}, RectList)
	
	self.List = {}
	self.Connectors = {}
	-- self.Scale = Vector2.new(5,5) --NO
	self.Dimensions = Vector2.new(0,0)
	
	return self
end

--Uses greedy meshing, Must be a Matrix created with Dagnabbit.Matrix
function RectList.fromMatrix(Matrix)
	--Uses greedy meshing to convert a matrix into a RectList
	local self = RectList.new()
	
	local ValsChecked = {} --i = (y - 1) * Rows + (x - 1) + 1 (non-simplified version, simplification is encouraged.)
	
	--TODO: Columns and Rows var are switched... oops...
	local Columns = Matrix.Dimensions.Y
	local Rows =  Matrix.Dimensions.X
	
	for y = 1, Columns do
		for x = 1, Rows do
			if ValsChecked[(y - 1) * Rows + x] == true then
				continue
			end
			
			local val = Matrix.Value[y][x]
			
			if val == nil then
				ValsChecked[(y - 1) * Rows + x] = true
				continue
			end
			
			local Max_X, Max_Y = x, y
			local suc = true
			
			--This while loop was a sort of ported version from my noobfall python script
			while suc do --Expand diagonally if it could.
				--Check diagonally
				
				if Max_X + 1 <= Rows and Max_Y + 1 <= Columns --Check ahead and see if that doesn't exceed the bounds
					and not ValsChecked[Max_Y * Rows + Max_X + 1] --Or has not been visited
					and Matrix.Value[Max_Y + 1][Max_X + 1] == val then --and is the same value.
					--Check from left to right
					for dx = x, Max_X + 1 do
						local curVal = Matrix.Value[Max_Y + 1][dx]
						if curVal ~= val or ValsChecked[Max_Y * Rows + dx] == true then
							suc = false
							break
						end
					end
					
					if not suc then
						break
					end

					--Check from top to down (TOP DOWN G)
					for dy = y, Max_Y + 1 do
						local curVal = Matrix.Value[dy][Max_X + 1] 
						if curVal ~= val or ValsChecked[(dy - 1) * Rows + Max_X + 1] == true then
							suc = false
							break
						end
					end

					if not suc then
						break
					end

					--NOW FINALLY WE CAN EXTEND DIAGONALLY!!!!
					Max_X += 1
					Max_Y += 1
				else
					suc = false
					break
				end

				if not suc then --idk why but for some reason it loops infinitely so this is here to prevent that... ╥w╥
					break
				end
			end

			--Now check Right
			suc = true
			while suc do
				--Check if it doesn't exceeds bounds
				if Max_X + 1 > Rows then
					break
				end
				--Check right
				for dy = y, Max_Y do
					local CurVal = Matrix.Value[dy][Max_X + 1]
					
					if val ~= CurVal or ValsChecked[(dy - 1) * Rows + Max_X + 1] == true then
						suc = false
						break
					end
				end

				if not suc then
					break
				end

				Max_X += 1
			end
			
			--Go Down
			suc = true
			while suc do --Issue in this loop...
				if Max_Y + 1 > Columns then
					break
				end
				
				for dx = x, Max_X do
					local CurVal = Matrix.Value[Max_Y + 1][dx]
					
					if val ~= CurVal or ValsChecked[Max_Y * Rows + dx ] == true then
						suc = false
						break
					end
				end

				if not suc then
					break
				end

				Max_Y += 1
			end
			
			-- Mark all covered cells as checked
		
			--print(x, y, Max_X, Max_Y)
			for fillY = y, Max_Y do
				for fillX = x, Max_X do
					ValsChecked[(fillY - 1) * Rows + fillX] = true
				end
			end
			

			--print(x, y, Max_X, Max_Y, val)
			self:Insert(Rect.new(x - 1, y - 1, Max_X, Max_Y), val)
		end
	end

	--Now rescale
	self:Rescale(Matrix.GridScale)

	self.Connectors = DeepCopy(Matrix.Connectors or {})
	-- self.Scale = Matrix.GridScale or self.Scale --NO
	self.Dimensions = Matrix.Dimensions
	return self
end

function RectList:Insert(RectVal:Rect, val)
	local NewRect = RectValMod.new(RectVal, val)
	
	table.insert(self.List, NewRect)
end

function RectList:Rescale(scale: Vector2)
	for i = 1, #self.List do
		local rect = self.List[i].Rect

		local min = Vector2.new(
			rect.Min.X * scale.X,
			rect.Min.Y * scale.Y
		)

		local max = Vector2.new(
			rect.Max.X * scale.X,
			rect.Max.Y * scale.Y
		)

		self.List[i].Rect = Rect.new(min, max)
	end
	
	self.Dimensions = Vector2.new(self.Dimensions.X * scale.X, self.Dimensions.Y * scale.Y)
end

function RectList:GetOverlapping(r:Rect)
	local AffectedRects = {}
	for i, v in pairs(self.List) do
		if RectUtils.Touching(v.Rect, r) then
			AffectedRects[i] = v
		end
	end
	
	return AffectedRects
end

--look up "computational geometry rectangle subtraction algorithm"
--Naming scheme is based on GCP https://en.wikipedia.org/wiki/General_Polygon_Clipper
function RectList:Difference(r:Rect, ExcludedValues:{string})
	local AffectedRects = self:GetOverlapping(r) --Tables are anonymous, these are the direct values.
	print(AffectedRects)
	
	local IndexesToRemove = {}
	
	for i, v in pairs(AffectedRects) do
		if ExcludedValues ~= nil and table.find(ExcludedValues, v.Value) then
			continue
		end
		local a:Rect = v.Rect
		
		if RectUtils.Covering(r, a) then
			table.insert(IndexesToRemove, i)
			continue
		end
		
		--Answer comes from here
		--https://stackoverflow.com/questions/16619835/clipping-a-rectangle-in-javascript
		local Rectangles = {}
		
		--Top
		if a.Min.Y < r.Min.Y then
			table.insert(Rectangles, Rect.new(
				a.Min.X,
				a.Min.Y,
				a.Max.X,
				r.Min.Y
			))
		end
		
		--Bottom
		if a.Max.Y > r.Max.Y then
			table.insert(Rectangles, Rect.new(
				a.Min.X,
				r.Max.Y,
				a.Max.X,
				a.Max.Y
			))
		end	
		
		--Left
		if a.Min.X < r.Min.X then
			table.insert(Rectangles, Rect.new(
				a.Min.X,
				math.max(a.Min.Y, r.Min.Y),
				r.Min.X,
				math.min(a.Max.Y, r.Max.Y)
			))
		end
		
		--Right
		if a.Max.X > r.Max.X then
			table.insert(Rectangles, Rect.new(
				r.Max.X,
				math.max(a.Min.Y, r.Min.Y),
				a.Max.X,
				math.min(a.Max.Y, r.Max.Y)
			))
		end
		
		for _, j in ipairs(Rectangles) do
			self:Insert(j, v.Value)
		end
		
		table.insert(IndexesToRemove, i)
	end
	
	warn(r)
	
	for _, i in ipairs(IndexesToRemove) do
		self.List[i] = nil
	end
	
	for i, v in pairs(self.List) do
		if v == nil then
			table.remove(i)
		end
	end
end

function RectList:GetRandomRectFromVal(val)
	local AllRectsWithVal = {}
	
	for i, v in ipairs(self.List) do
		if v.Value == val then
			table.insert(AllRectsWithVal, v)
		end
	end
	
	if #AllRectsWithVal == 0 then
		return 
	end
	
	return AllRectsWithVal[math.random(1, #AllRectsWithVal)]
end

function RectList:GenerateList(BlueprintSelected)
	local Model = Instance.new("Model")

	for i, v in pairs(self.List) do	
		local GenPart = v:Generate(BlueprintSelected)
		if GenPart then
			GenPart.Name = tostring(i)
			GenPart.Parent = Model
		end
	end

	return Model
end

return RectList