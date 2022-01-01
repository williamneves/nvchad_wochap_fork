local M = {}

M.setup_lsp = function(attach, capabilities)
  local lspconfig = require "lspconfig"
  -- TODO: add clangd vimls pyls_ms?
  local servers = {
    "html",
    "cssls",
    "emmet_ls",
    "jsonls",
    "svelte",
    "tailwindcss",
    "bashls",
    "tsserver",
    "sumneko_lua",
    "flow",
    "cssmodules_ls",
    "rnix",
    "statix",
  }

  for _, lsp in ipairs(servers) do
    local opts = {
      on_attach = attach,
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 150,
      },
    }

    -- typescript
    if lsp == "tsserver" then
      opts.on_attach = function(client, bufnr)
        -- Run nvchad's attach
        attach(client, bufnr)
        
        -- disable tsserver's inbuilt formatting 
        -- since I use null-ls for formatting
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false

        -- enable document_highlight
        client.resolved_capabilities.document_highlight = true
      end
    end

    -- json
    if lsp == "jsonls" then
      local present, schemastore = pcall(require, "schemastore")

      if present then
        opts.settings = {
          json = {
            schemas = schemastore.json.schemas(),
          },
        }
      end 
    end

    -- emmet
    if lsp == "emmet_ls" then
      opts.filetypes = { "html", "css", "scss" }
    end

    lspconfig[lsp].setup(opts)
  end

  vim.diagnostic.config {
    severity_sort = true,
    signs = false,
    virtual_text = false,
    float = {
      format =  function(diagnostic)
        return string.format("%s (%s)", diagnostic.message, diagnostic.source)
      end
    },
  }
end

return M
