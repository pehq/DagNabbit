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
			
			local val = Matrix[y][x]

			if val == nil then
				ValsChecked[(y - 1) * Columns + (x - 1) + 1] = true
				continue
			end

			local Max_X, Max_Y = x, y
			local XCheck, YCheck = true, true
			--Expand diagonally
			while XCheck and YCheck do
				Max_X += 1
				Max_Y += 1

				--Check y
				for dy = y, Max_Y do
					if ValsChecked[(dy - 1) * Columns + (Max_X - 1) + 1] == true then
						YCheck = false
						break
					end
					
					local curval = Matrix.Value[dy][Max_X]
					if curval ~= val then
						YCheck = false
						break
					end
				end
				if not YCheck then
					break
				end

				--Check x
				for dx = x, Max_X do
					if ValsChecked[(Max_Y - 1) * Columns + (dx - 1) + 1] == true then
						XCheck = false
						break
					end

					local curval = Matrix.Value[Max_Y][dx]
					if curval ~= val then
						YCheck = false
						break
					end
				end
			end

			RectList:Insert(Rect.new(x, y, Max_X - 1, Max_Y - 1), val)
		end
	end
	
	self.Connectors = DeepCopy(Matrix.Connectors or {})
	self.Scale = Matrix.Scale
	return self
end

function RectList:Insert(RectVal:Rect, val)
	local NewRect = RectValMod.new(RectVal, val)
	
	table.insert(self.List, NewRect)
end

function RectList:GenerateList()
	local Model = Instance.new("Model")

	for i, v in pairs(self.List) do
		local GenPart = v:Generate()
		GenPart.Name = tostring(i)
	end

	return Model
end

return RectList