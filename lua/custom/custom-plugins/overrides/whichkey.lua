local M = {}

local wk = require "which-key"

M.setup = function()
  wk.register({
    o = { name = "neorg" },
    c = { name = "utils" },
    g = { name = "git" },
    f = { name = "find" },
    h = { name = "harpon" },
    p = { name = "lazy" },
    q = { name = "quit" },
    t = { name = "todo" },
    T = { name = "terminal" },
    x = { name = "trouble" },
  }, { prefix = "<leader>" })
end

return M
