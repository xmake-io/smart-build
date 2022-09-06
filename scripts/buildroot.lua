
-- imports
import("menuconf", {
    alias = "load_menuconf"
})
import("core.base.option")
import("core.base.json")
import("core.project.config")
import("core.project.project")
import("core.cache.localcache")
import("core.platform.platform")
import("private.action.require.install", {
    alias = "install_packages"
})
import("private.action.require.impl.utils.get_requires")
import("private.action.require.impl.package")
import("private.action.require.impl.environment")


function build_package(configs)
       -- load platform instance
       local platform_inst = platform.load()

       -- clear local cache
       localcache.clear()

       -- check platform and toolchains
       platform_inst:check()

       local lib_install_path = ""
       if configs["arch"] == "arm" then
           lib_install_path = "$(projectdir)" .. "/../sdk/lib/arm/cortex-a/"
           for _, rcfile in ipairs(os.files(path.join(os.scriptdir(), "toolchains", "arm.lua"))) do
               os.addenv("XMAKE_RCFILES", rcfile)
           end
       else
           lib_install_path = "$(projectdir)" .. "/../sdk/lib/aarch64/cortex-a/"
           for _, rcfile in ipairs(os.files(path.join(os.scriptdir(), "toolchains", "aarch64.lua"))) do
               os.addenv("XMAKE_RCFILES", rcfile)
           end
       end
       
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
               -- static library
               os.cp(package_inst:installdir("lib") .. "/*.a", lib_install_path)
               -- dynamic library
               os.cp(package_inst:installdir("lib") .. "/*.so", "$(projectdir)/../root/lib/")
           end

           if os.exists(package_inst:installdir("include")) then
               os.cp(package_inst:installdir("include") .. "/*.h", "$(projectdir)" .. "/../sdk/include/")
           end
       end
    return 0
end


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

    if option.get("build") then
        if os.exists(".config") then
            local configs  = json.loadfile(".config")
            for name, value in pairs(configs) do
                config.set(name, value, {readonly = false})
            end
            build_package(configs)
        end
    end

    -- menuconfig
    if option.get("menuconfig") then
        -- load configuration from menu
        local configs = load_menuconf()
        for name, value in pairs(configs) do
            config.set(name, value, {readonly = true})
        end
        build_package(configs)
    end

end
