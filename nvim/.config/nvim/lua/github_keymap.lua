local M = {}

function M.open_file_on_github(branch_option)
  local file_path = vim.fn.expand '%:p'
  local line_number = vim.fn.line '.'

  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not inside a Git repository'
    return
  end

  local relative_path = vim.fn.fnamemodify(file_path, ':~:.')
  relative_path = file_path:sub(#git_root + 2)

  -- Get the current branch name
  local branch = vim.fn.systemlist('git symbolic-ref --short HEAD')[1]
  if branch_option == 'default' then
    -- Get the default branch of the remote repository
    local remote_info = vim.fn.systemlist 'git remote show origin'
    for _, line in ipairs(remote_info) do
      local default_branch = line:match 'HEAD branch: (.*)'
      if default_branch then
        branch = default_branch
        break
      end
    end
  elseif branch == '' then
    branch = 'main' -- Fallback to main
  end

  local remote_url = vim.fn.systemlist('git config --get remote.origin.url')[1]
  if remote_url == '' then
    return
  end

  -- Convert SSH URL to HTTPS if necessary
  if remote_url:match '^git@' then
    remote_url = remote_url:gsub('^git@', 'https://')
    remote_url = remote_url:gsub('(com):', '%1/')
  end
  remote_url = remote_url:gsub('%.git$', '')

  local github_url = string.format('%s/blob/%s/%s#L%d', remote_url, branch, relative_path, line_number)

  -- vim.fn.system(string.format('xdg-open "%s"', github_url))
  -- For now use a Mac specific command to open the URL
  vim.fn.system(string.format('open "%s"', github_url))
end

return M
