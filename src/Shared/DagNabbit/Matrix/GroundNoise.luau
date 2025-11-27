--This generation is used for the ClassicPartsGround Blueprint

local Noise = {}

-- Greyscale + height quantization steps
local steps = {0, 0.2, 1, 1.2}

--Refer to this graph
local function quantize(v)
	if v < 0.3 then
		return 1
	elseif v < 0.5 then
		return 2
	elseif v < 0.66 then
		return 3
	else
		return 4
	end
end

--scale is the size of the parts. Frequency should be between 0 and 1.
--Lower frequency makes the noise more smooth (in other words, you zoom into the noise.)
--NoiseSeed should be a decimal.
function Noise.new(self, freq:number?, noiseseed:number?, offset:Vector2?)
	if freq == nil then freq = 0.03 end
	if noiseseed == nil then noiseseed = math.random() end
	if offset == nil then offset = Vector2.zero end
	
	local size = self.Dimensions
	
	for y = 1, size.Y, 1 do
		for x = 1, size.X, 1 do
			-- Raw noise 0–1
			local raw = (math.noise((x + offset.X) * freq, (y + offset.Y) * freq, noiseseed) + 1) / 2
			
			-- Quantize noise value
			local q = steps[quantize(raw)]
			
			self.Value[y][x] = q
		end
	end
end

return Noise