
local gen_parse = function()
	local function parse(s, index, t, str_acc, stack)
		local head = s:sub(1, 1)
		local tail = s:sub(2)
		local top = stack[#stack]

		if head == "" then 
            if(str_acc ~= "") then
                table.insert(t, str_acc)
            end
			return true, index-1
		elseif head == " " or head == "\t" or head == "\n" or head == "\r" then
			if top == '"' then
				str_acc = str_acc .. head
				return parse(tail, index+1, t, str_acc, stack)
			end
			if str_acc ~= "" then
				table.insert(t, str_acc)
                str_acc = ""
			end
			return parse(tail, index+1, t, str_acc, stack)
		elseif head == "(" then
			if str_acc ~= "" then
				table.insert(t, str_acc)
			end

			local child = {}
			table.insert(t, child)
			table.insert(stack, child) 

			str_acc = ""
			return parse(tail, index+1, child, str_acc, stack)
		elseif head == ")" then
			if type(top) ~= 'table' then
                error("Unexpected top element")
			end
			table.remove(stack, #stack)

			if str_acc ~= "" then
				table.insert(t, str_acc)
			end
			str_acc = ""

			local parent = stack[#stack]

			if not parent then
				return false, "Stack underflow: no matching '(' for  ')' at column " .. tostring(index)
			end

			return parse(tail, index+1, parent, str_acc, stack)
		elseif head == '"' then
			if top == '"' then
				table.remove(stack, #stack)
				table.insert(t, str_acc)
				str_acc = ""
				return parse(tail, index+1, t, str_acc, stack)
			else
                if str_acc ~= "" then
                    table.insert(t, str_acc)
                end
				table.insert(stack, '"')
				str_acc = ""
				return parse(tail, index+1, t, str_acc, stack)
			end
		else
			str_acc = str_acc .. head
			return parse(tail, index+1, t, str_acc, stack)
		end
	end

	local function parse_sexpr(s)
        local t = {}
		local stack = {t}
		local res, details = parse(s, 1, t, "", stack)
		if not res then
			return false, details
		end

		local index = details

		if #stack > 1 then
			return false, "Unbalanced: stack not empty after processing"
		end

		if #t > 1 then
			return false, "Invalid syntax: high level enclosing (...) missing"
		end

        return t[1], index
	end

	return parse_sexpr
end


return {
    parse = gen_parse(),
}

