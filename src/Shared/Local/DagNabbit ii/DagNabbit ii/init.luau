--Dungeon with Algorithmic Generator with a Nonsensical Abacus that Backstabs you with Bewildered Imaginary Tunnels
--DagNabbit's second coming (basically it's rescripted)

--Dagnabbit houses different formats of maps, using different functions for maximum efficiency

--Matrix
-- A 2D map that is basically a tile.
-- It is easy to work with but is inefficient to generate

--Hyper-Matrix
-- Like Matrix but with infinite dimensions instead of 2
-- Anything past 3 dimensions will result in catastrophic Ram usuage, Ram usuage is exponential per Dimensions.
-- For a reference of how much memory it would take, here's a reference from c++ book i found.
-- char century [100][365][24][60][60]; --> 3 billion chars --> 3 GBs!!! (Roblox's server memory is limited to this!)

--Psuedo-Matrix
-- Like Hyper-Matrix but without the issues of being bloated with memory.
-- It is a 1D table that represents Infinite dimensions (kinda like how a 3d cube can be represented by a 2d screen.).

--Rect
-- Instead of a grid, this is a series of rectangles.
-- This helps with efficiently generating the map.
-- It is tough to set values with this as a entirely new Rect map would have to be created.

local DagNabbit = {}

for i, v in pairs(script:GetChildren()) do
	if v:IsA("ModuleScript") then
		DagNabbit[v.Name] = require(v)
	end
end

return DagNabbit
