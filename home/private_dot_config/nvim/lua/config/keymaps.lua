-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Delete without yanking
keymap.set("n", "x", '"_x')

-- Increment/decrement (more intuitive than C-a/C-x)
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
