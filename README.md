# npm-runner.nvim

- npm-runner.nvim is an configuration for run npm, pnpm yarn bun ect

# Instalation

- Lazy

```lua
{
  "pojokcodeid/npm-runner.nvim",
  dependencies = {
    "rcarriga/nvim-notify",
  },
  -- your opts go here
  opts = {
    command={
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
    },
    opt={
      show_mapping = "<leader>nm",
      hide_mapping = "<leader>nh",
      width = 70,
      height = 20,
    }
  },
  -- stylua: ignore
  config = function(_, opts)
    require("npm-runner").setup(opts.command, opts.opt)
  end,
},
```

Minimum Config :

```lua
require("npm-runner").setup()
```

Default User Command :

- :NpmRunDev
- :NpmStopDev
- :NpmRun
- :NpmStop

default opts :

```lua
{
  command={
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
  },
  opt={
    show_mapping = "<leader>nm",
    hide_mapping = "<leader>nh",
    width = 70,
    height = 20,
  }
}
```
