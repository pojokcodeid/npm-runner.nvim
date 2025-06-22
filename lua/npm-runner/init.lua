local M = {}
M.setup = function(command, opts)
  command = command
    or {
      dev = {
        start = "NpmRunDev",
        stop = "NpmStopDev",
        cmd = "npm run dev",
      },
      prod = {
        start = "NpmStart",
        stop = "NpmStop",
        cmd = "npm start",
      },
    }
  opts = opts
    or {
      show_mapping = "<leader>nm",
      hide_mapping = "<leader>nh",
      width = 70,
      height = 20,
    }
  require("npm-runner.utils").setup(command, opts)
end

return M
