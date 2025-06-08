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
			self:Insert(Rect.new(x, y, Max_X, Max_Y), val)
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

function RectList:Rescale(scale:Vector2) --TODO: there's a problem here
	for i = 1, #self.List do
		local curRectVal = self.List[i]
		
		curRectVal.Rect = Rect.new(curRectVal.Rect.Min, Vector2.new((curRectVal.Rect.Width + 1) * scale.X, (curRectVal.Rect.Height + 1) * scale.Y))
	end
end

function RectList:GetOverlapping(r:Rect)
	local AffectedRects = {}
	for i = 1, #self.List do
		local curRect:{Rect:Rect, Value:any} = self.List[i]
		if RectUtils.Touching(curRect, r) then
			AffectedRects[i] = curRect
		end
	end
	
	return AffectedRects
end

function RectList:Cut(r:Rect)
	local AffectedRects = self:GetOverlapping(r) --Tables are anonymous, these are the direct values.
		
	for i, v in pairs(AffectedRects) do
		local a:Rect = v.Rect
		
		if RectUtils.Covering(r, a) then
			self.List[i] = nil
			continue
		end
		-- Original rect bounds
		local x1, y1 = a.x, a.y
		local x2, y2 = a.x + a.w, a.y + a.h
		
		-- Negator bounds
		local nx1, ny1 = r.x, r.y
		local nx2, ny2 = r.x + r.w, r.y + r.h
		
		-- Intersection bounds
		local ix1 = math.max(x1, nx1)
		local iy1 = math.max(y1, ny1)
		local ix2 = math.min(x2, nx2)
		local iy2 = math.min(y2, ny2)
		
		-- Top slice
		if y1 < iy1 then
			self:Insert(Rect.new(x1, y1, a.Width, iy1 - y1), v.Value)
		end
		
		--Bottom Slice
		if iy2 < y2 then
			self:Insert(Rect.new(x1, iy2, a.Width, y2 - iy2), v.Value)
		end
		
		--Left slice
		if x1 < ix1 then
			self:Insert(Rect.new(x1, iy1, ix1 - x1, iy2 - iy1), v.Value)
		end

		--Right Slice
		if ix2 < x2 then
			self:Insert(Rect.new(ix2, iy1, x2 - ix2, iy2 - iy1), v.Value)
		end
		
		self.List[i] = nil
	end
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