-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.colorscheme = 'catppuccin-macchiato'

lvim.plugins = {
	{ 'catppuccin/nvim', name = 'catppuccin' },
	{ 'norcalli/nvim-colorizer.lua' },
	{
		'ray-x/lsp_signature.nvim',
		config = function ()
			require 'lsp_signature'.setup {
				floating_window = false,
				hint_enable = true,
				hint_prefix = ''
			}
		end
	}
}

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = false

lvim.keys.normal_mode['<leader>r'] = '<cmd>ClangdSwitchSourceHeader<CR>'
