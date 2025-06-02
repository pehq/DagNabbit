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

	local ValsChecked = {} --i = (y - 1) * columns + (x - 1) + 1

	local Columns = Matrix.Dimensions.Y
	local Rows =  Matrix.Dimensions.X
	--Set all nil as checked
	for y = 1, Columns do
		for x = 1, Rows do
			local val = Matrix.Value[y][x]
			if val == nil then
				ValsChecked[(y - 1) * Columns + (x - 1) + 1] = true
			end
		end
	end

	for y = 1, Columns do
		for x = 1, Rows do
			if ValsChecked[(y - 1) * Columns + (x - 1) + 1] == true then
				continue
			end
			
			local val = Matrix.Value[y][x]

			if val == nil then
				ValsChecked[(y - 1) * Columns + (x - 1) + 1] = true
				continue
			end
			
			local Max_X, Max_Y = x, y
			local suc = true
			
			--This while loop was a sort of ported version from my noobfall python script
			while suc do
				-- Try to expand one more row
				if Max_Y + 1 <= Columns then
					for checkX = x, Max_X do
						if Matrix.Value[Max_Y + 1][checkX] ~= val or ValsChecked[(Max_Y) * Columns + checkX] then
							suc = false
							break
						end
					end
					if suc then
						Max_Y += 1
					end
				else
					suc = false
				end

				-- Try to expand one more column
				if suc and Max_X + 1 <= Rows then
					for checkY = y, Max_Y do
						if Matrix.Value[checkY][Max_X + 1] ~= val or ValsChecked[(checkY - 1) * Columns + Max_X + 1] then
							suc = false
							break
						end
					end
					if suc then
						Max_X += 1
					end
				else
					suc = false
				end

						-- If couldn't expand in both, try Down-only
				if Max_X == x and Max_Y == y then
					while Max_Y + 1 <= Columns and Matrix.Value[Max_Y + 1][x] == val and not ValsChecked[Max_Y * Columns + x] do
						Max_Y += 1
					end
				end
		
				-- If still a single tile, try Right-only
				if Max_X == x and Max_Y == y then
					while Max_X + 1 <= Rows and Matrix.Value[y][Max_X + 1] == val and not ValsChecked[(y - 1) * Columns + Max_X + 1] do
						Max_X += 1
					end
				end
		
				-- Mark all covered cells as checked
				for fillY = y, Max_Y do
					for fillX = x, Max_X do
						ValsChecked[(fillY - 1) * Columns + fillX] = true
					end
				end
			end

			--print(x, y, Max_X, Max_Y, val)
			self:Insert(Rect.new(x, y, Max_X, Max_Y), val)
		end
	end
	
	self.Connectors = DeepCopy(Matrix.Connectors or {})
	self.Scale = Matrix.Scale or self.Scale
	self:SetScaleAll(self.Scale)
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