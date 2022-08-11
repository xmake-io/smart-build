
-- imports
import("menuconf", {
    alias = "load_menuconf"
})
import("core.base.option")
import("core.project.config")
import("core.project.project")
import("core.cache.localcache")
import("core.platform.platform")
import("private.action.require.install", {
    alias = "install_packages"
})
import("private.action.require.impl.package")


function main()

    -- rm build dir
    if option.get("clean") then
        os.rm(os.projectdir() .. "/build")
    end

    -- rm build and all install pkg dir
    if option.get("distclean") then
        os.rm(os.projectdir() .. "/build")
        os.rm(os.getenv("HOME") .. "/.xmake/packages/*")
    end

    -- menuconfig
    if option.get("menuconfig") then
        -- load configuration from menu
        load_menuconf()

        -- load platform instance
        local platform_inst = platform.load()

        -- clear local cache
        localcache.clear()

        -- check platform and toolchains
        platform_inst:check()

        -- install packages
        install_packages()

        -- export packages to build directory
        local buildir = config.buildir()
        local requires, requires_extra = project.requires_str()
        for _, package_inst in ipairs(package.load_packages(requires, {requires_extra = requires_extra, nodeps = nodeps})) do
            if not os.exists(buildir) then
                os.mkdir(buildir .. "/bin")
                os.mkdir(buildir .. "/lib")
                os.mkdir(buildir .. "/include")
                os.mkdir(buildir .. "/config")
            end

            if os.exists(package_inst:installdir("bin")) then
                os.cp(package_inst:installdir("bin") .. "/*",  "$(projectdir)/../root/bin/")
            end

            if os.exists(package_inst:installdir("lib")) then
                os.cp(package_inst:installdir("lib") .. "/*.a", buildir .. "/lib")
            end

            if os.exists(package_inst:installdir("include")) then
                os.cp(package_inst:installdir("include") .. "/*", buildir .. "/include")
            end
        end
    end

    -- build

end
