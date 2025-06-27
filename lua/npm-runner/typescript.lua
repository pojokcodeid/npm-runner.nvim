-- create TS Project
local function ts_new_project()
    local function create_notif(message, level)
        local notif_ok, notify = pcall(require, "notify")
        if notif_ok then
        notify(message, level)
        else
        print(message)
        end
    end

    local function get_user_input(prompt, default_value)
        vim.fn.inputsave()
        local result = vim.fn.input(prompt, default_value)
        vim.fn.inputrestore()
        if result == "" then
        create_notif("Input canceled.", "info")
        return nil, true
        end
        return result, false
    end

    -- Input nama project
    local project_name, canceled = get_user_input("Enter TypeScript project name: ", "my-ts-app")
    if canceled then
        return
    end

    local cwd = vim.fn.getcwd()
    local project_path = cwd .. "/" .. project_name

    -- Validasi jika folder sudah ada
    if vim.fn.isdirectory(project_path) == 1 then
        create_notif("Project directory already exists: " .. project_path, "error")
        return
    end

    create_notif("Cloning starter template... (harap tunggu)", "info")
    -- Clone repo starter
    local git_clone_cmd =
        string.format("git clone --depth=1 https://github.com/pojokcodeid/typescript-starter-app '%s'", project_path)
    local git_clone_res = os.execute(git_clone_cmd)

    if git_clone_res ~= 0 or vim.fn.isdirectory(project_path) == 0 then
        create_notif("Failed to clone typescript-starter-app!", "error")
        return
    end

    -- Hapus folder .git agar tidak ikut repo asal
    vim.fn.system(string.format("rm -rf '%s/.git'", project_path))

    create_notif("Running npm install...", "info")
    vim.fn.jobstart("npm install", {
        cwd = project_path,
        detach = false,
        on_stdout = function(_, data)
        if data and type(data) == "table" then
            local msg = table.concat(
            vim.tbl_filter(function(line)
                return line and line ~= ""
            end, data),
            "\n"
            )
            if msg ~= "" then
            create_notif("npm install: " .. msg, "info")
            end
        end
        end,
        on_stderr = function(_, data)
        if data and type(data) == "table" then
            local msg = table.concat(
            vim.tbl_filter(function(line)
                return line and line ~= ""
            end, data),
            "\n"
            )
            if msg ~= "" then
            create_notif("npm install error: " .. msg, "error")
            end
        end
        end,
        on_exit = function(_, code)
        if code == 0 then
            create_notif("npm install finished", "info")
        else
            create_notif("npm install failed", "error")
        end
        end,
    })

    -- Buka project, NvimTree, src/index.ts, insert mode
    vim.cmd("cd " .. project_path)
    local index_file = project_path .. "/src/index.ts"

    if vim.fn.exists(":NvimTreeOpen") == 2 then
        vim.cmd("NvimTreeOpen")
        vim.schedule(function()
        vim.cmd("edit " .. index_file)
        local last_line = vim.api.nvim_buf_line_count(0)
        vim.api.nvim_win_set_cursor(0, { last_line, 0 })
        vim.cmd("startinsert")
        end)
    else
        vim.cmd("edit " .. index_file)
        local last_line = vim.api.nvim_buf_line_count(0)
        vim.api.nvim_win_set_cursor(0, { last_line, 0 })
        vim.cmd("startinsert")
    end
end

vim.api.nvim_create_user_command("TsNewProject", ts_new_project, {})
