local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
  return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.update_capabilities(M.capabilities)

M.setup = function()
  local signs = {

    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    virtual_text = false, -- disable virtual text
    signs = {
      active = signs, -- show signs
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_keymaps(bufnr)
  local apimap = vim.api.nvim_buf_set_keymap
  local keymap = vim.keymap.set
  keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: [R]e[n]ame", buffer = bufnr })
	keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: [C]ode [A]ction", buffer = bufnr })

	keymap("n", "gd", vim.lsp.buf.definition, { desc = "LSP: [G]oto [D]efinition", buffer = bufnr })
	keymap("n", "gr", require("telescope.builtin").lsp_references, { desc = "LSP: [G]oto [R]eferences", buffer = bufnr })
	keymap("n", "gI", vim.lsp.buf.implementation, { desc = "LSP: [G]oto [I]mplementation", buffer = bufnr })
	keymap("n", "<leader>gt", vim.lsp.buf.type_definition, { desc = "LSP: [G]oto [T]ype definition", buffer = bufnr })
	keymap("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, { desc = "LSP: [D]ocument [S]ymbols", buffer = bufnr })
	keymap("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, { desc = "LSP: [W]orkspace [S]ymbols", buffer = bufnr })

	-- See `:help K` for why this keymap
	keymap("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation", buffer = bufnr })
	keymap("n", "<leader>k", vim.lsp.buf.signature_help, { desc = "LSP: Signature Documentation", buffer = bufnr })

	-- Lesser used LSP functionality
	keymap("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: [G]oto [D]eclaration", buffer = bufnr })
	keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "LSP: [W]orkspace [A]dd Folder", buffer = bufnr })
	keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "LSP: [W]orkspace [R]emove Folder", buffer = bufnr })
	keymap("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, { desc = "LSP: [W]orkspace [L]ist Folders", buffer = bufnr })

  apimap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Diagnostics: Open Float", noremap = true, silent = true })
  apimap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", { desc = ":LspInfo", noremap = true, silent = true })
  apimap(bufnr, "n", "<leader>lI", "<cmd>Mason<cr>", { desc = ":Mason", noremap = true, silent = true })
  apimap(bufnr, "n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", { desc = "Diagnostics: Goto Next", noremap = true, silent = true })
  apimap(bufnr, "n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", { desc = "Diagnostics: Goto Prev", noremap = true, silent = true })
  apimap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", { desc = "Diagnostics: Add to Location List", noremap = true, silent = true })
end

M.on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.name == "sumneko_lua" then
    client.server_capabilities.documentFormattingProvider = false
  end

  lsp_keymaps(bufnr)
  local status_ok, illuminate = pcall(require, "illuminate")
  if not status_ok then
    return
  end
  illuminate.on_attach(client)
end

return M
