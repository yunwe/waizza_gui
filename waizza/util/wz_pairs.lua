-- Waizza Gui
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

-- - Pair function
-- @function wz_pairs

-- It sort the table by it's value and return an iterator 
-- @param t the table to iterate
-- @param f the sort function
-- @return an iterator function
local function wz_pairs (t, f)
	assert(t, "Table is not defined.")
	assert(f, "Sorting function cannot be nil.")
	
	local a = {}
	for key, val in pairs(t) do 
		val.__key = key
		table.insert(a, val) 
	end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else
			local key = a[i].__key
			a[i].__key = nil
			return key, a[i]
		end
	end
	return iter
end

return wz_pairs