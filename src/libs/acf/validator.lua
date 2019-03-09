--------------------------------------------------
-- Validation Functions for Alpine Linux' Webconf
--------------------------------------------------
local mymodule = {}

local format = require("libs.acf.format")

function mymodule.is_string ( str )
	return (type(str) == "string")
end

function mymodule.is_boolean ( str )
	return (type(str) == "boolean")
end

function mymodule.is_number ( str )
	return (type(str) == "number")
end

--
-- This function validates an ipv4 address.
--
function mymodule.is_ipv4(ipv4)
	local retval = false;
	local nums = {};
	local iplen = string.len(ipv4);

	-- check the ipv4's length
	if (iplen < 7 or iplen > 15) then
		return false, "Invalid Length"
	end

	-- NC: Split the string into an array. separate with '.' (dots)
	-- ^	beginning of string
	-- ()	capture
	-- %.	litteral '.' The % neutralizes the . character class.
	-- %d+	one or more digits
	-- $	end of string
	nums = {ipv4:match ("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")}

	-- check if all nums are filled
	if ( nums[1] == nil or
		nums[2] == nil or
		nums[3] == nil or
		nums[4] == nil) then
		-- we have an empty number
		return false, "Invalid Format"
	end

	-- too big?
	if (tonumber(nums[1]) > 255 or
			tonumber(nums[2]) > 255 or
			tonumber(nums[3]) > 255 or
			tonumber(nums[4]) > 255) then
		-- at least one number is too big
		return false, "Invalid Value"
	end

	return true
end

--
-- This function validates a partial ipv4 address.
--
function mymodule.is_partial_ipv4(ipv4)
	local retval = false;
	local nums = {};

	-- Check to see if any invalid characters
	if not ipv4 or not ipv4:match("^[%d%.]+$") then
		return false, "Invalid Format"
	end

	-- NC: Split the string into an array. separate with '.' (dots)
	-- %d+	one or more digits
	for num in ipv4:gmatch("%d+") do
		nums[#nums+1] = num
		-- too big?
		if tonumber(num) > 255 then
			return false, "Invalid Format"
		end
	end

	-- too many numbers
	if #nums > 4 then
		return false, "Invalid Format"
	end

	return true
end

function mymodule.is_mac(mac)

	local tmpmac = string.upper(mac)

	if (string.len(tmpmac) ~= 17) then
		return false, "Invalid Length"
	end

	-- check for valid characters
	local step = 1;
	while (step <= 17) do
		if (string.sub(tmpmac, step, step) ~= ":") and
			 (string.sub(tmpmac, step, step) < "0" or string.sub(tmpmac, step, step) > "9") and
			 (string.sub(tmpmac, step, step) < "A" or string.sub(tmpmac, step, step) > "F") then
			-- we have found an invalid character!
			return false, "Invalid Chars"
		end
		step = step + 1;
	end

	-- check for valid colon positions
	if (string.sub(tmpmac, 3, 3) ~= ":" or
			string.sub(tmpmac, 6, 6) ~= ":" or
			string.sub(tmpmac, 9, 9) ~= ":" or
			string.sub(tmpmac, 12, 12) ~= ":" or
			string.sub(tmpmac, 15, 15) ~= ":") then
		return false, "Invalid Format"
	end

	-- check for valid non colon positions
	step = 1;
	while (step <= 17) do
		if ((string.sub(tmpmac, step, step) == ":") and
				((step ~= 3) and (step ~= 6) and (step ~= 9) and (step ~= 12) and
				 (step ~= 15))) then
			return false, "Invalid Value"
		end
		step = step + 1;
	end

	return true
end

--
-- This function checks if the given input
-- consists of number-chars between 0..9 only
-- and eventually a leading '-'
--
function mymodule.is_integer(numstr)
	-- ^   beginning of string
	-- -?  one or zero of the char '-'
	-- %d+ one or more digits
	-- $   end of string
	return string.find(numstr, "^-?%d+$") ~= nil
end


--
-- This function checks if the given input
-- consists of number-chars between 0..9 only
-- and if it is within a given range.
--
function mymodule.is_integer_in_range(numstr, min, max)
	return mymodule.is_integer(numstr)
		and tonumber(numstr) >= min
		and tonumber(numstr) <= max

end

--
-- This function checks if the given number is an integer
-- and wheter it is between 1 .. 65535
--
function mymodule.is_port(numstr)
	return mymodule.is_integer_in_range(numstr, 1, 65535)
end

function mymodule.is_valid_filename ( path, restriction )
	if not (path) or ((restriction) and (string.find (path, "^" .. format.escapemagiccharacters(restriction) ) == nil or string.find (path, "/", #restriction+2) )) then
		return false
	end
	return true
end

return mymodule
