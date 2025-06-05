local DeepCopy = require(script.Parent.Utils.DeepCopy)
local RectValMod = require(script.RectVal)

local RectList = {}
RectList.__index = RectList

function RectList.new()
	local self = setmetatable({}, RectList)
	
	self.List = {}
	self.Connectors = {}
	self.Scale = Vector2.new(5,5)

	return self
end

--Uses greedy meshing, Must be a Matrix created with Dagnabbit.Matrix
function RectList.fromMatrix(Matrix)
	--Uses greedy meshing to convert a matrix into a RectList
	local self = RectList.new()
	
	local ValsChecked = {} --i = (y - 1) * Rows + (x - 1) + 1 (non-simplified version, simplification is encouraged.)
	
	local DEBUG = true
	--TODO: Columns and Rows var are switched... oops...
	local Columns = Matrix.Dimensions.Y
	local Rows =  Matrix.Dimensions.X
	
	for y = 1, Columns do
		for x = 1, Rows do
			print(x, y , ValsChecked[(y - 1) * Rows + x])
			if ValsChecked[(y - 1) * Rows + x] == true then
				continue
			end
			print(true)
			
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
					if DEBUG == true and ValsChecked[1 - 1 * Rows + 8] == true then
						print(fillX, fillY)
						DEBUG = false
					end
				end
			end
			

			--print(x, y, Max_X, Max_Y, val)
			self:Insert(Rect.new(x, y, Max_X, Max_Y), val)
		end
	end
	
	self.Connectors = DeepCopy(Matrix.Connectors or {})
	self.Scale = Matrix.GridScale or self.Scale
	self:SetScaleAll(self.Scale)
	self.Dimensions = Matrix.Dimensions
	return self
end

function RectList:Insert(RectVal:Rect, val)
	local NewRect = RectValMod.new(RectVal, val)
	
	table.insert(self.List, NewRect)
end

function RectList:SetScaleAll(scale)
	for i, v in pairs(self.List) do
		v.Scale = scale
	end
end

function RectList:GenerateList()
	local Model = Instance.new("Model")

	for i, v in pairs(self.List) do	
		local GenPart = v:Generate()
		if GenPart then
			GenPart.Name = tostring(i)
			GenPart.Parent = Model
		end
	end

	return Model
end

return RectList