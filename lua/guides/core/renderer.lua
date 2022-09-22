local utils = require('guides.utils')

local nsid = vim.api.nvim_create_namespace('bracket')
local nsid_opts = {
	virt_text_pos = 'overlay',
	hl_mode = 'combine',
	virt_text = {}
}

---@enum
local line_guides = {
	'─', '┌', '▏', '└', '>'
}

local M = {}

M.bracket = function()
	-- Remove previously created extmarks
	utils.clear_namespace(nsid)

	-- Get the start and end position of the bracket
	local positions = utils.findPairs()

	-- Edge case
	if positions.start_pos.line == 0 or positions.end_pos.line == 0 then
		return
	end

	local space_text = utils.getChars(vim.fn.shiftwidth(), ' ')
	local start_line = vim.api.nvim_buf_get_lines(0, positions.start_pos.line - 1, positions.start_pos.line, true)[1]
	local end_line = vim.api.nvim_buf_get_lines(0, positions.end_pos.line - 1, positions.end_pos.line, true)[1]

	start_line = utils.replace_line_content(start_line, space_text)
	end_line = utils.replace_line_content(end_line, space_text)

	local length_start = string.len(start_line)
	local length_end = string.len(end_line)
	local space_len = math.min(length_start - vim.fn.shiftwidth(), length_end - vim.fn.shiftwidth())
	local indent = utils.line_indent(positions.start_pos.line)

	space_len = math.max(space_len, 0)

	if length_start == 1 then
		local virtual_text = line_guides[1]
		nsid_opts.virt_text = { { virtual_text, 'BracketUnderline' } }
		vim.api.nvim_buf_set_extmark(0, nsid, positions.start_pos.line - 1, 0, nsid_opts)
	end
	if length_start >= 2 then
		local aux_start_line = string.sub(start_line, (indent * vim.fn.shiftwidth()) + 1)
		if positions.start_pos.line == positions.end_pos.line then
			aux_start_line = string.sub(start_line, positions.start_pos.col + (indent * vim.fn.shiftwidth()) - 2,
				positions.end_pos.col + (indent * vim.fn.shiftwidth()) - 2)
			indent = positions.start_pos.col - 1
		end
		local virtual_text = aux_start_line
		nsid_opts.virt_text = { { virtual_text, 'BracketUnderline' } }
		vim.api.nvim_buf_set_extmark(0, nsid, positions.start_pos.line - 1, indent, nsid_opts)
	end

	if length_end == 1 then
		local virtual_text = end_line
		nsid_opts.virt_text = { { virtual_text, 'BracketUnderline' } }
		vim.api.nvim_buf_set_extmark(0, nsid, positions.end_pos.line - 1, 0, nsid_opts)
	end
	if length_end >= 2 then
		local virtual_text = string.sub(end_line, indent * vim.fn.shiftwidth() + 1)
		nsid_opts.virt_text = { { virtual_text, 'BracketUnderline' } }
		vim.api.nvim_buf_set_extmark(0, nsid, positions.end_pos.line - 1, indent, nsid_opts)
	end

	-- Calculate visible edge of screen
	local edges = utils.calc_visibleEdges(positions)

	for i = edges.visible_start + 1, edges.visible_end - 1, 1 do
		local c_line = vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1]
		c_line = string.gsub(c_line, '\t', space_text)
		if string.sub(c_line, space_len, 1) ~= '\\s' or string.len(c_line) <= space_len then
			local virtual_text = line_guides[3]
			nsid_opts.virt_text = { { virtual_text, 'BracketLine' } }
			vim.api.nvim_buf_set_extmark(0, nsid, i - 1, indent, nsid_opts)
		end
	end
end

return M
