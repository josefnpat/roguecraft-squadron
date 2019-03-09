--[[
	module for format changes in tables and strings
	try to keep non input specific
]]--

local mymodule = {}

-- find all return characters and removes them, may get this from a browser
-- that is why didn't do file specific

function mymodule.dostounix ( str )
	local data = string.gsub(str, "\r", "")
	return data
end

-- Escape Lua magic characters
function mymodule.escapemagiccharacters ( str )
	return (string.gsub(str or "", "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"))
end

-- Escape shell special characters
function mymodule.escapespecialcharacters ( str )
	return (string.gsub(str or "", "[~`#%$&%*%(%)\\|%[%]{};\'\"<>/\n\r]", "\\%1"))
end

function mymodule.formatfilesize ( size )
	size = tonumber(size) or 0
	if ( size > 1073741824 ) then
		return ((size/1073741824) - (size/1073741824%0.1)) .. "G"
	elseif ( size > 1048576 ) then
		return ((size/1048576) - (size/1048576%0.1))  .. "M"
	elseif ( size > 1024 ) then
		return ((size/1024) - (size/1024%0.1)) .. "k"
	else
		return tostring(size)
	end
end

function mymodule.formattime ( time )
	if tonumber(time) then
		return os.date("%c", time)
	else
		return "---"
	end
end

-- search and remove all blank and commented lines from a string or table of lines
-- returns a table to iterate over without the blank or commented lines

function mymodule.parse_lines ( input, comment )
	local lines = {}
	comment = comment or "#"

	function parse(line)
		if not string.match(line, "^%s*$") and not string.match(line, "^%s*"..comment) then
			lines[#lines + 1] = line
		end
	end

	if type(input) == "string" then
		for line in string.gmatch(input, "([^\n]*)\n?") do
			parse(line)
		end
	elseif type(input) == "table" then
		for i,line in ipairs(input) do
			parse(line)
		end
	end

	return lines
end

-- search and remove all blank and commented lines from a string or table of lines
-- parse the lines for words, looking for quotes and removing comments
-- returns a table with an array of words for each line

function mymodule.parse_linesandwords ( input, comment )
	local lines = {}
	local linenum = 0
	comment = comment or "#"

	function parse(line)
		linenum = linenum + 1
		if not string.match(line, "^%s*$") and not string.match(line, "^%s*"..comment) then
			local linetable = {linenum=linenum, line=line}
			local offset = 1
			while string.find(line, "%S", offset) do
				local word = string.match(line, "%S+", offset)
				local endword
				if string.find(word, "^"..comment) then
					break
				elseif string.find(word, "^\"") then
					endword = select(2, string.find(line, "\"[^\"]*\"", offset))
					word = string.sub(line, string.find(line, "\"", offset), endword)
				else
					endword = select(2, string.find(line, "%S+", offset))
				end
				table.insert(linetable, word)
				offset = endword + 1
			end
			lines[#lines + 1] = linetable
		end
	end

	if type(input) == "string" then
		for line in string.gmatch(input, "([^\n]*)\n?") do
			parse(line)
		end
	elseif type(input) == "table" then
		for i,line in ipairs(input) do
			parse(line)
		end
	end

	return lines
end

-- returns a table with label value pairs

function mymodule.parse_configfile( input, comment )
	local config = {}
	local lines = mymodule.parse_linesandwords(input, comment)

	for i,linetable in ipairs(lines) do
		config[linetable[1]] = table.concat(linetable, " ", 2) or ""
	end
	return config
end

-- search and replace through a table
-- string is easy string.gsub(string, find, replace)

function mymodule.search_replace (input, find, replace)
	local lines = {}
	for i,line in ipairs(input) do
		lines[#lines + 1] = string.gsub(line, find, replace)
	end
	return lines
end

-- great for line searches through a file. /etc/conf.d/ ???
-- might be looking for more than one thing so will return a table
-- will likely want to match whole line entries
-- so we change find to include the rest of the line
-- say want all the _OPTS from a file format.search_for_lines (fs.read_file("/etc/conf.d/cron"), "OPT")
-- if want to avoid commented lines, call parse_lines first

function mymodule.search_for_lines (input, find)
	local lines = {}

	function findfn(line)
		if string.find(line, find) then
			lines[#lines + 1] = line
		end
	end

	if type(input) == "string" then
		for line in string.gmatch(input, "([^\n]*)\n?") do
			findfn(line)
		end
	elseif type(input) == "table" then
		for i,line in ipairs(input) do
			findfn(line)
		end
	end

	return lines
end

--string format function to capitalize the beginging of each word.
function mymodule.cap_begin_word ( str )
	--first need to do the first word
	local data = string.gsub(str, "^%l", string.upper)
	--word is any space cause no <> regex
	data = string.gsub(data, "%s%l", string.upper)
	return data
end

--for cut functionality do something like
--print(format.string_to_table("This is a test", " ")[2])
--gives you the second field which is .... is

-- This code comes from http://lua-users.org/wiki/SplitJoin
-- example: format.string_to_table( "Anna, Bob, Charlie,Dolores", ",%s*")
function mymodule.string_to_table ( text, delimiter)
	local list = {}
	if text then
		-- this would result in endless loops
		if string.find("", delimiter) then
			-- delimiter matches empty string!
			for i=1,#text do
				list[#list + 1] = string.sub(text, i, i)
			end
		else
			local pos = 1
			while 1 do
				local first, last = string.find(text, delimiter, pos)
				if first then -- found?
					table.insert(list, string.sub(text, pos, first-1))
					pos = last+1
				else
					table.insert(list, string.sub(text, pos))
					break
				end
			end
		end
	end
	return list
end


-- Takes a str and expands any ${...} constructs with the Lua variable
-- ex: a="foo"; print(expand_bash_syntax_vars("a=${a}) - > "a=foo"
mymodule.expand_bash_syntax_vars = function (str)
	local deref = function (f)
		local v = getfenv(3) -- get the upstream global env
		for w in string.gfind(f, "[%w_]+") do
			if v then v = v[w] end
		end
		return v
	end

	for w in string.gmatch (str, "${[^}]*}" ) do
		local rvar = string.sub(w,3,-2)
		local rval = ( deref(rvar) or "nil" )
		str = string.gsub (str, w, mymodule.escapespecialcharacters(rval))
	end

	return (str)
end

-- Removes the linenum line from str and replaces it with line.
-- Do nothing if doesn't exist
-- Set line to nil to remove the line
function mymodule.replace_line(str, linenum, line)
	-- Split the str to remove the line
	local startchar, endchar = string.match(str, "^" .. string.rep("[^\n]*\n", linenum-1) .. "()[^\n]*\n?()")
	if startchar and endchar then
		local lines = {}
		lines[1] = string.sub(str, 1, startchar-1)
		lines[2] = string.sub(str, endchar, -1)
		if line then
			table.insert(lines, 2, line .. "\n")
		end
		str = table.concat(lines)
	end
	return str
end

-- Inserts the line into the str after the linenum (or at the end)
function mymodule.insert_line(str, linenum, line)
	-- Split the str to remove the line
	local startchar = string.match(str, "^" .. string.rep("[^\n]*\n", linenum) .. "()")
	local lines = {}
	if startchar then
		lines[1] = string.sub(str, 1, startchar-1)
		lines[2] = string.sub(str, startchar, -1)
	else
		lines[1] = str
	end
	if line then
		table.insert(lines, 2, line .. "\n")
	end
	str = table.concat(lines)
	return str
end

function mymodule.get_line(str, linenum)
	-- Split the str to remove the line
	local startchar, endchar = string.match(str, "^" .. string.rep("[^\n]*\n", linenum-1) .. "()[^\n]*()")
	local line
	if startchar and endchar then
		line = string.sub(str, startchar, endchar-1)
	end
	return line
end

-- Search the option string for separate options (-x or --xyz) and put them in a table
function mymodule.opts_to_table ( optstring, filter )
	local optsparams
	if optstring then
		local optstr = optstring .. " "
		for o in string.gmatch(optstr, "%-%-?%a+%s+[^-%s]*") do
			local option = string.match(o, "%-%-?%a+")
			if not filter or filter == option then
				if not optsparams then optsparams = {} end
				optsparams[option] = string.match(o, "%S*$")
			end
		end
	end
	return optsparams
end

-- Go through an options table and create the option string
function mymodule.table_to_opts ( optsparams )
	local optstring = {}
	for opt,val in pairs(optsparams) do
		optstring[#optstring + 1] = opt
		if val ~= "" then
			optstring[#optstring + 1] = val
		end
	end
	return table.concat(optstring, " ")
end

-- The following functions deal with ini files.  ini files contain comments, sections, names and values
-- 	commented lines begin with '#' or ';', in-line comments begin with '#' and run to the end of the line
-- 	sections are defined by "[section]" on a line.  Anything before the first section definition is in section ""
--	name value pairs are defined by "name = value".  Names and values may contain spaces but not '#'
--	lines ending with '\' are continued on the next line


-- Set a name=value pair in a string
-- If search_section is undefined or "", goes in the default section
-- If value is defined we put "search_name=value" into search_section
-- If value is undefined, we clear search_name out of search section
-- Try not to touch anything but the value we're interested in (although will combine multi-line into one)
-- If the search_section is not found, we'll add it at the end of the string
-- If the search_name is not found, we'll add it at the end of the section
function mymodule.update_ini_file (file, search_section, search_name, value)
	if not file or not search_name or search_name == "" then
		return file, false
	end

	search_section = search_section or ""
	local new_conf_file = {}
	local section = ""
	local done = false
	local skip_lines = {}
	for l in string.gmatch(file, "([^\n]*)\n?") do
		if done == false then
			if string.find ( l, "\\%s*$" ) then
				skip_lines[#skip_lines+1] = string.match(l, "^(.*)\\%s*$")
				l = nil
			else
				if #skip_lines then
					skip_lines[#skip_lines+1] = l
					l = table.concat(skip_lines, " ")
				end
				-- check if comment line
				if not string.find ( l, "^%s*[#;]" ) then
					-- find section name
					local a = string.match ( l, "^%s*%[%s*(%S+)%s*%]" )
					if a then
						-- we reached a new section, if we were in the one we wanted
						-- we have to add in the name:value pair now
						if (search_section == section) then
							new_conf_file[#new_conf_file + 1] = search_name.."="..value
							done = true
						end
						section = a
					elseif (search_section == section) then
						-- find name
						a = string.match ( l, "^%s*([^=]*%S)%s*=" )
						if a and (search_name == a) then
							-- We found the name, change the value, keep any comment
							local comment = string.match(l, " #.*$") or ""
							l = search_name.."="..value..comment
							skip_lines = {}	-- replacing line
							done = true
						end
					end
				end
				if #skip_lines > 0 then
					for i,line in ipairs(skip_lines) do
						new_conf_file[#new_conf_file + 1] = line
					end
					skip_lines = {}
					l = nil
				end
			end
		end
		new_conf_file[#new_conf_file + 1] = l
	end

	if done == false then
		-- we didn't find the section:name, add it now
		if section ~= search_section then
			new_conf_file[#new_conf_file + 1] = '[' .. search_section .. ']'
		end
		new_conf_file[#new_conf_file + 1] = search_name.."="..value
	end

	file = table.concat(new_conf_file, '\n')

	return file, true
end

-- Parse string for name=value pairs, returned in a table
-- If search_section is defined, only report values in matching section
-- If search_name is defined, only report matching name (possibly in multiple sections)
function mymodule.parse_ini_file (file, search_section, search_name)
	if not file or file == "" then
		return nil
	end
	local opts = nil
	local section = ""
	local skip_lines = {}
	for l in string.gmatch(file, "([^\n]*)\n?") do
		if string.find ( l, "\\%s*$" ) then
			skip_lines[#skip_lines+1] = string.match(l, "^(.*)\\%s*$")
		else
			if #skip_lines then
				skip_lines[#skip_lines+1] = l
				l = table.concat(skip_lines, " ")
				skip_lines = {}
			end
			-- check if comment line
			if not string.find ( l, "^%s*[#;]" ) then
				-- find section name
				local a = string.match ( l, "^%s*%[%s*(%S+)%s*%]" )
				if a then
					if (search_section == section) then break end
					section = a
				elseif not (search_section) or (search_section == section) then
					-- find name
					a = string.match ( l, "^%s*([^=]*%S)%s*=" )
					if a and (not (search_name) or (search_name == a)) then
						-- Figure out the value
						local b = string.match ( l, '=%s*(.*)$' ) or ""
						-- remove comments from end of line
						if string.find ( b, '#' ) then
							b = string.match ( b, '^(.*)#.*$' ) or ""
						end
						-- remove spaces from front and back
						b = string.gsub ( b, '%s+$', '' )
						if not (opts) then opts = {} end
						if not (opts[section]) then opts[section] = {} end
						opts[section][a] = b
					end
				end
			end
		end
	end

	if opts and search_section and search_name then
		return opts[search_section][search_name]
	elseif opts and search_section then
		return opts[search_section]
	end
	return opts
end

function mymodule.get_ini_section (file, search_section)
	if not file then
		return nil
	end
	search_section = search_section or ""
	local sectionlines = {}
	local section = ""
	for l in string.gmatch(file, "([^\n]*)\n?") do
		-- find section name
		local a = string.match ( l, "^%s*%[%s*(%S+)%s*%]" )
		if a then
			if (search_section == section) then break end
			section = a
		elseif (search_section == section) then
			sectionlines[#sectionlines + 1] = l
		end
	end

	return table.concat(sectionlines, "\n")
end

function mymodule.set_ini_section (file, search_section, section_content)
	if not file then
		return file, false
	end
	search_section = search_section or ""
	section_content = section_content or ""
	local new_conf_file = {}
	local done = false
	local section = ""
	if search_section == "" then new_conf_file[1] = section_content end
	for l in string.gmatch(file, "([^\n]*)\n?") do
		-- find section name
		if not done then
			local a = string.match ( l, "^%s*%[%s*(%S+)%s*%]" )
			if a then
				if (search_section == section) then
					done = true
				else
					section = a
					if (search_section == section) then
						l = l .. "\n" .. section_content
					end
				end
			elseif (search_section == section) then
				l = nil
			end
		end
		new_conf_file[#new_conf_file + 1] = l
	end

	if not done then
		-- we didn't find the section, add it now
		if section ~= search_section then
			new_conf_file[#new_conf_file + 1] = '[' .. search_section .. ']'
			new_conf_file[#new_conf_file + 1] = section_content
		end
	end

	file = table.concat(new_conf_file, '\n')

	return file, true
end

-- Find the value of an entry allowing for parent section and $variables
-- the file parameter can be a string or structure returned by parse_ini_file
-- beginning and ending quotes are removed
-- returns value or "" if not found
function mymodule.get_ini_entry (file, section, value)
	local opts = file
	if not file or not value then
		return nil
	elseif type(file) == "string" then
		opts = mymodule.parse_ini_file(file)
	end
	section = section or ""
	local result
	if opts and opts[section] then
		result = opts[section][value]
	end
	if not result then
		section = ""
		if opts and opts[section] then
			result = opts[section][value] or ""
		else
			result = ""
		end
	end
	while string.find(result, "%$[%w_]+") do
		local sub = string.match(result, "%$[%w_]+")
		result = string.gsub(result, mymodule.escapemagiccharacters(sub), mymodule.get_ini_entry(opts, section, sub))
	end
	if string.find(result, '^"') and string.find(result, '"$') then
		result = string.sub(result, 2, -2)
	end
	return result
end

return mymodule
