local brGuid = require('guides.core.renderer')
local utils = require('guides.utils')

local M = {}

M.init = function()
	utils.setup_hl()
	vim.api.nvim_create_autocmd(
		{ 'CursorMoved', 'CursorMovedI', 'TextChanged', 'TextChangedI' },
		{
			pattern = { "*.lua", "*.ts" },
			callback = function()
				brGuid.bracket()
			end
		}
	)
end

return M
