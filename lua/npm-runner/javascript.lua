-- js new project
local function js_new_project()
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
local project_name, canceled = get_user_input("Enter project name: ", "my-js-app")
if canceled then
    return
end

-- Input file entry point (bisa src/index.js, index.js, src/main/index.js, dsb)
local file_path_input, canceled = get_user_input(
    "Enter entry file name \n(\nindex.js, \nsrc/index.js, \nsrc/main/index.js\n): ",
    "src/index.js"
)
if canceled then
    return
end

-- Input nama function utama
local function_name, canceled = get_user_input("Enter main function name: ", "main")
if canceled then
    return
end

local cwd = vim.fn.getcwd()
local project_path = cwd .. "/" .. project_name

if vim.fn.isdirectory(project_path) == 1 then
    create_notif("Project directory already exists: " .. project_path, "error")
    return
end

-- Dapatkan folder dan filename dari file_path_input
local folder_part = file_path_input:match("(.+)/[^/]+%.js$") or "" -- e.g. "src/main" or ""
local file_name_part = file_path_input:match("([^/]+)%.js$") -- e.g. "index"

-- Buat project folder dan subfolder jika ada
local full_folder_path = (folder_part ~= "") and (project_path .. "/" .. folder_part) or project_path
vim.fn.system(string.format("mkdir -p '%s'", full_folder_path))

-- path file entry point absolut
local entry_file = string.format("%s/%s.js", full_folder_path, file_name_part)

-- Buat package.json dengan "main" dan scripts dinamis
local package_json = string.format(
[[
{
    "name": "%s",
    "version": "1.0.0",
    "main": "%s",
    "scripts": {
        "test": "echo \"Error: no test specified\" && exit 1",
        "start": "node %s",
        "dev": "nodemon %s"
    },
    "author": "",
    "license": "ISC",
    "devDependencies": {
        "nodemon": "^3.1.0"
    }
}
]],
    project_name,
    file_path_input,
    file_path_input,
    file_path_input
)
local package_json_path = project_path .. "/package.json"
local pkg_file = io.open(package_json_path, "w")
if pkg_file then
    pkg_file:write(package_json)
    pkg_file:close()
end

-- Tambahkan generate jsconfig.json
local jsconfig = [[
{
    "compilerOptions": {
        "module": "commonjs",
        "target": "es6",
        "allowSyntheticDefaultImports": true
    },
    "exclude": ["node_modules"],
    "include": ["**/*.js"]
}
]]
local jsconfig_path = project_path .. "/jsconfig.json"
local jsconfig_file = io.open(jsconfig_path, "w")
if jsconfig_file then
    jsconfig_file:write(jsconfig)
    jsconfig_file:close()
end

-- Template kode JS
local js_code = string.format(
[[
function %s() {

}

%s();
]],
    function_name,
    function_name
)

local file = io.open(entry_file, "w")
if file then
    file:write(js_code)
    file:close()
    create_notif("JavaScript project created at " .. project_path, "info")
    vim.cmd("cd " .. project_path)

    -- Jalankan npm install (async, biar tidak blok nvim)
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

    -- Jika ada NvimTreeOpen, jalankan lalu fokus ke file JS
    if vim.fn.exists(":NvimTreeOpen") == 2 then
    vim.cmd("NvimTreeOpen")
    vim.schedule(function()
        vim.cmd("edit " .. entry_file)
        local lines = {}
        for line in js_code:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
        end
        local func_line = 1
        for i, line in ipairs(lines) do
        if line:find("function%s+" .. function_name .. "%s*%(") then
            func_line = i
            break
        end
        end
        local target_line = func_line + 1
        vim.api.nvim_win_set_cursor(0, { target_line, 2 })
        vim.cmd("startinsert")
    end)
    else
    vim.cmd("edit " .. entry_file)
    local lines = {}
    for line in js_code:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end
    local func_line = 1
    for i, line in ipairs(lines) do
        if line:find("function%s+" .. function_name .. "%s*%(") then
        func_line = i
        break
        end
    end
    local target_line = func_line + 1
    vim.api.nvim_win_set_cursor(0, { target_line, 2 })
    vim.cmd("startinsert")
    end
else
    create_notif("Failed to create file: " .. entry_file, "error")
end
end
vim.api.nvim_create_user_command("JsNewProject", js_new_project, {})
