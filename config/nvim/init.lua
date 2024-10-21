-- Basic Setup
vim.opt.compatible = false             -- Disable compatibility with old Vi
vim.opt.laststatus = 2                 -- Always show the status line
vim.opt.termguicolors = true           -- Enable 256 colors in the terminal
vim.opt.encoding = "utf-8"             -- Set encoding to UTF-8
vim.opt.autoindent = true              -- Enable auto-indenting
vim.opt.magic = true                   -- Enable enhanced pattern matching

-- Interface and Display
vim.opt.number = true                  -- Show line numbers
vim.opt.scrolloff = 10                 -- Keep 10 lines above and below the cursor when scrolling (was 3, set to 10 as per new config)
vim.opt.sidescroll = 3                 -- Keep 3 columns to the side when scrolling horizontally
vim.opt.ruler = true                   -- Show cursor position at the bottom of the window
vim.opt.colorcolumn = "80"             -- Highlight column 80
vim.opt.wrap = false                   -- Disable line wrapping
vim.opt.breakindent = true             -- Enable break indent for long lines (new setting)
vim.opt.cursorline = true              -- Highlight the current line (new setting)

-- Searching
vim.opt.ignorecase = true              -- Ignore case when searching (no conflict)
vim.opt.smartcase = true               -- Override ignorecase if search includes uppercase letters
vim.opt.incsearch = true               -- Incremental search
vim.opt.showmatch = true               -- Highlight matching parentheses
vim.opt.hlsearch = true                -- Highlight search results

-- Splits and File Management
vim.opt.splitbelow = true              -- Horizontal splits open below (no conflict)
vim.opt.splitright = true              -- Vertical splits open to the right (new setting)
vim.opt.hidden = true                  -- Allow hidden buffers
vim.opt.swapfile = false               -- Disable swap files
vim.opt.undofile = true                -- Enable persistent undo (new setting)
vim.opt.foldenable = false             -- Disable code folding

-- Miscellaneous
vim.opt.timeout = false                -- Disable timeout for mapped sequences
vim.opt.timeoutlen = 200               -- Set timeout length for key sequences (new setting)
vim.opt.mouse = "a"                    -- Enable mouse support
vim.opt.lazyredraw = true              -- Redraw only when necessary for performance
vim.opt.clipboard = "unnamedplus"      -- Use system clipboard (new setting)
vim.opt.showmode = true                -- Display mode in the command area (new setting)
vim.opt.updatetime = 100               -- Faster update interval for cursor hold (new setting)

-- Colorscheme
vim.cmd("colorscheme wildcharm")      -- Set colorscheme (new setting)
vim.opt.background = "dark"           -- Set background to light (new setting)
--vim.cmd("colorscheme lunaperche")      -- Set colorscheme (new setting)
--vim.opt.background = "light"           -- Set background to light (new setting)

-- File-Specific Settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 80        -- Set text width to 80 characters
    vim.opt_local.expandtab = true      -- Expand tabs to spaces
    vim.opt_local.tabstop = 2           -- Set tab stop to 2 spaces
    vim.opt_local.shiftwidth = 2        -- Set shift width to 2 spaces
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "text",
  callback = function()
    vim.opt_local.textwidth = 80        -- Set text width to 80 characters
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "progress",
  callback = function()
    vim.opt_local.filetype = ""         -- Clear filetype for progress files
  end
})
