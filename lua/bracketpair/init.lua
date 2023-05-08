local renderer = require('bracketpair.core.renderer')
local utils = require('bracketpair.utils')

local M = {}

M.init = function()
	utils.setup_hl()
	vim.api.nvim_create_autocmd(
		{ 'CursorMoved', 'CursorMovedI', 'TextChanged', 'TextChangedI' },
		{
			pattern = { "*" },
			callback = function()
				renderer.bracket()
			end
		}
	)
end

return M
