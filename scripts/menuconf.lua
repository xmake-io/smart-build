-- imports
import("core.base.option")
import("core.base.json")
import("core.project.config")
import("core.project.project")
import("core.ui.log")
import("core.ui.rect")
import("core.ui.view")
import("core.ui.label")
import("core.ui.event")
import("core.ui.action")
import("core.ui.menuconf")
import("core.ui.mconfdialog")
import("core.ui.application")


-- the app application
local app = application()

-- init app
function app:init()

    -- init name
    application.init(self, "app.config")

    -- init background
    self:background_set("blue")

    -- insert menu config dialog
    self:insert(self:mconfdialog())
    -- load configs
    self:load(not option.get("clean"))
end

-- get menu config dialog
function app:mconfdialog()
    if not self._MCONFDIALOG then
        local mconfdialog = mconfdialog:new("app.config.mconfdialog", rect {1, 1, self:width() - 1, self:height() - 1},
            "menu config")
        mconfdialog:action_set(action.ac_on_exit, function(v)
            self:quit()
            os.exit()
        end)
        mconfdialog:action_set(action.ac_on_save, function(v)
            self:save()
            self:quit()
        end)
        self._MCONFDIALOG = mconfdialog
    end
    return self._MCONFDIALOG
end

-- on resize
function app:on_resize()
    self:mconfdialog():bounds_set(rect {1, 1, self:width() - 1, self:height() - 1})
    application.on_resize(self)
end

-- get or make menu by category
function app:_menu_by_category(root, configs, menus, category)

    -- is root?
    if category == "." or category == "" then
        return
    end

    -- attempt to get menu first
    local menu = menus[category]
    if not menu then

        -- get config path
        local parentdir = path.directory(category)
        local config_path = path.join(root, parentdir == "." and "" or parentdir)

        -- make a new menu
        menu = menuconf.menu {
            name = category,
            path = config_path,
            description = path.basename(category),
            configs = {}
        }
        menus[category] = menu

        -- insert to the parent or root configs
        local parent = self:_menu_by_category(root, configs, menus, parentdir)
        table.insert(parent and parent.configs or configs, menu)
    end
    return menu
end

-- make configs by category
function app:_make_configs_by_category(root, options_by_category, cache, get_option_info)

    -- make configs category
    --
    -- root category: "."
    -- category path: "a", "a/b", "a/b/c" ...
    --
    local menus = {}
    local configs = {}
    local categories = table.orderkeys(options_by_category)
    for _, category in ipairs(categories) do

        -- get or make menu by category
        local options = options_by_category[category]
        local menu = self:_menu_by_category(root, configs, menus, category)

        -- get sub-configs
        local subconfigs = menu and menu.configs or configs

        -- insert options to sub-configs
        for _, opt in ipairs(options) do

            -- get option info
            local info = get_option_info(opt)
            -- new value?
            local newvalue = true

            -- load value
            local value = nil
            if cache then
                value = config.get(info.name)
                if value ~= nil and info.kind == "choice" and info.values then
                    for idx, val in ipairs(info.values) do
                        if value == val then
                            value = idx
                            break
                        end
                    end
                end
                if value ~= nil then
                    newvalue = false
                end
            end

            -- find the menu index in subconfigs
            local menu_index = #subconfigs + 1
            for idx, subconfig in ipairs(subconfigs) do
                if subconfig.kind == "menu" then
                    menu_index = idx
                    break
                end
            end

            -- get config path
            local config_path = path.join(root, category == "." and "" or category)
            -- insert config before all sub-menus
            if info.kind == "string" then
                table.insert(subconfigs, menu_index, menuconf.string {
                    name = info.name,
                    value = value,
                    new = newvalue,
                    default = info.default,
                    path = config_path,
                    description = info.description
                })
            elseif info.kind == "boolean" then
                table.insert(subconfigs, menu_index, menuconf.boolean {
                    name = info.name,
                    value = value,
                    new = newvalue,
                    default = info.default,
                    path = config_path,
                    description = info.description
                })
            elseif info.kind == "choice" then
                table.insert(subconfigs, menu_index, menuconf.choice {
                    name = info.name,
                    value = value,
                    new = newvalue,
                    default = info.default,
                    path = config_path,
                    values = info.values,
                    description = info.description
                })
            end
        end
    end
    return configs
end

-- get project configs
function app:_project_configs(cache)
    -- get configs from the cache first
    local configs = self._PROJECT_CONFIGS
    if configs then
        return configs
    end

    -- merge options by category
    local options = project.options()
    local options_by_category = {}
    local keys = table.orderkeys(options)
    for _, key in ipairs(keys) do
        local opt = options[key]
        local category = "."
        if opt:get("category") then
            category = table.unwrap(opt:get("category"))
        end
        options_by_category[category] = options_by_category[category] or {}
        table.insert(options_by_category[category], opt)
    end
    -- make configs by category
    self._PROJECT_CONFIGS = self:_make_configs_by_category("Project Configuration", options_by_category, cache,
        function(opt)

            -- the default value
            local default = "auto"
            if opt:get("default") ~= nil then
                default = opt:get("default")
            end

            -- get kind
            local kind = (type(default) == "string") and "string" or "boolean"

            -- get description
            local description = opt:get("description")

            -- choice option?
            local values = opt:get("values")
            if values then
                kind = "choice"
                for idx, value in ipairs(values) do
                    if default == value then
                        default = idx
                        break
                    end
                end
            end
            return {
                name = opt:name(),
                kind = kind,
                default = default,
                values = values,
                description = description
            }
        end)
    return self._PROJECT_CONFIGS
end

-- save the given configs
function app:_save_configs(configs, results)
    for _, conf in pairs(configs) do
        if conf.kind == "menu" then
            self:_save_configs(conf.configs, results)
        elseif conf.kind == "boolean" or conf.kind == "string" then
            results[conf.name] = conf.value
        elseif conf.kind == "choice" then
            results[conf.name] = conf.values[conf.value]
        end
    end
    json.savefile(".config", results)
end

-- load configs from options
function app:load(cache)
    -- clear configs first
    self._PROJECT_CONFIGS = nil

    -- load configs
    self:mconfdialog():load(self:_project_configs(cache))
end

-- save configs
local results = {}
function app:save()
    self:_save_configs(self:_project_configs(), results)
end

-- main entry
function main(...)
    if os.exists(".config") then
        results = json.loadfile(".config")
        for name, value in pairs(results) do
            config.set(name, value, {readonly = false})
        end
    end
    app:run(...)
    return results;
end
