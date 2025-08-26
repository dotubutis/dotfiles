local lint = require 'lint'

local severity_map = {
  ['fatal'] = vim.diagnostic.severity.ERROR,
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
  ['convention'] = vim.diagnostic.severity.HINT,
  ['refactor'] = vim.diagnostic.severity.INFO,
  ['info'] = vim.diagnostic.severity.INFO,
}

local rubocop = {
  cmd = 'bin/rubocop',
  stdin = true,
  args = {
    '--format',
    'json',
    '--force-exclusion',
    '--server',
    '--stdin',
    function()
      return vim.api.nvim_buf_get_name(0)
    end,
  },
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}
    local decoded = vim.json.decode(output)

    if not decoded.files[1] then
      return diagnostics
    end

    local offences = decoded.files[1].offenses

    for _, off in pairs(offences) do
      table.insert(diagnostics, {
        source = 'rubocop',
        lnum = off.location.start_line - 1,
        col = off.location.start_column - 1,
        end_lnum = off.location.last_line - 1,
        end_col = off.location.last_column,
        severity = severity_map[off.severity],
        message = off.message,
        code = off.cop_name,
      })
    end

    return diagnostics
  end,
}

lint.linters.bundle_rubocop = rubocop

lint.linters_by_ft = {
  typescript = { 'eslint' },
  typescriptreact = { 'eslint' },
  ruby = { 'bundle_rubocop' },
}

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function()
    lint.try_lint()
  end,
})
