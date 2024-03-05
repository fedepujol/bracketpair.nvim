-- Utilities
local M = {}

---Set bracket highlights groups
M.setup_hl = function()
	local _, hl = pcall(vim.api.nvim_get_hl, 0, { name = "MatchParen", link = true })
	local color = hl.foreground or "cyan"

	vim.api.nvim_set_hl(0, "BracketUnderline", { sp = color, underline = true })
	vim.api.nvim_set_hl(0, "BracketLine", { fg = color, underline = false })
end

---@param lineNr number
---@return number
M.line_indent = function(lineNr)
	return vim.fn.indent(lineNr) / vim.fn.shiftwidth()
end

---Finds the position (line, col) of the curly-brackets
---@param line number current line number
---@param col number current column number
---@return table
M.findPairs = function(line, col)
	local cLine = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]

	local sPos = vim.fn.searchpairpos("{", "", "}", "znWb" .. (string.sub(cLine, col, 1) == "{" and "c" or ""))
	local ePos = vim.fn.searchpairpos("{", "", "}", "znW" .. (string.sub(cLine, col, 1) == "}" and "c" or ""))
	return {
		start_pos = {
			line = sPos[1],
			col = sPos[2],
		},
		end_pos = {
			line = ePos[1],
			col = ePos[2],
		},
	}
end

---@param length number
---@param character string
---@return string
M.getChars = function(length, character)
	local result = ""

	for i = 1, length, 1 do
		result = result .. character
	end

	return result
end

---@param nsid number
M.clear_namespace = function(nsid)
	vim.api.nvim_buf_clear_namespace(0, nsid, 0, -1)
end

---@param line string
---@param space_text string
---@return string
M.replace_line_content = function(line, space_text)
	-- avoid nil values coming from line or space_text
	-- string.gsub takes only string values and will throw annoying errors if it gets nil
	if not line or line == "" then
		return line
	end
	space_text= space_text or ""
	line = string.gsub(line, "\v^(\\s*).*", "\\1")
	line = string.gsub(line, "\t", space_text)
	return line
end

---@param positions table
---@return table
M.calc_visibleEdges = function(positions)
	local visible_start = positions.start_pos.line
	local visible_end = positions.end_pos.line

	if positions.end_pos.line - positions.start_pos.line > 100 then
		visible_start = math.max(positions.start_pos.line, vim.fn.line("w0") - 50)
		visible_end = math.min(positions.end_pos.line, vim.fn.line("w$") + 50)
	end

	return {
		visible_start = visible_start,
		visible_end = visible_end,
	}
end

---
---@param temp_col number
---@return boolean
M.should_skip_char = function(temp_col)
	local col = temp_col + 1
	local line = vim.api.nvim_get_current_line()
	local cChar = string.sub(line, col, col)

	return cChar == "}" or cChar == "{"
end

return M
