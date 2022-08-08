package("lua")

    set_homepage("http://lua.org")
    set_description("A powerful, efficient, lightweight, embeddable scripting language.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/lua-$(version).tar.gz")

    add_versions("5.1.4", "b038e225eaf2a5b57c9bcc35cd13aa8c6c8288ef493d52970c9545074098af3a")

    add_includedirs("include/lua")
    if not is_plat("windows") then
        add_syslinks("dl", "m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("cross", "linux", "macosx", "windows", "android", "bsd", function (package)
	--import("core.base.option")
	--print(option.get("includes"))
        local sourcedir = os.isdir("src") and "src/" or "" -- for tar.gz or git source
        io.writefile("xmake.lua", format([[
            local sourcedir = "%s"
            local pd = os.getenv("PROJ_DIR")

            toolchain("rt_toolchain")
                set_kind("standalone")
                set_sdkdir(pd .. "/../../tools/gnu_gcc/install_arm-linux-musleabi_for_x86_64-pc-linux-gnu")
                on_load(function(toolchain)
                    toolchain:load_cross_toolchain()
                    toolchain:set("toolset", "cxx", "arm-linux-musleabi-g++")
                    -- add flags for arch
                    toolchain:add("cxflags", "-march=armv7-a -marm -msoft-float -O0 -g -gdwarf-2  -Wall -n --static", {force = true}) 
                    toolchain:add("ldflags", "-march=armv7-a -marm -msoft-float -O0 -g -gdwarf-2  -Wall -n --static", {force = true})
                    toolchain:add("ldflags", "-T " .. pd  .. "/../linker_scripts/arm/cortex-a/link.lds", {force = true})
                    toolchain:add("ldflags", "-Wl,--whole-archive -lrtthread -Wl,--no-whole-archive", {force = true})
                    toolchain:add("ldflags", "-Wl,--start-group -lrtthread -Wl,--end-group", {force = true})
                    toolchain:add("includedirs", pd .. "/../sdk/rt-thread/include")
                    toolchain:add("includedirs", pd .. "/../sdk/rt-thread/components/dfs")
                    toolchain:add("includedirs", pd .. "/../sdk/rt-thread/components/drivers")
                    toolchain:add("includedirs", pd .. "/../sdk/rt-thread/components/finsh")
                    toolchain:add("includedirs", pd .. "/../sdk/rt-thread/components/net")
                    toolchain:add("linkdirs", pd .. "/../sdk/rt-thread/lib")
                end)
            toolchain_end()

            target("lualib")
                set_kind("static")
                set_basename("lua")
		set_toolchains("rt_toolchain")
                add_headerfiles(sourcedir .. "*.h", {prefixdir = "lua"})
                add_files(sourcedir .. "*.c|lua.c|luac.c|onelua.c")
                add_defines("LUA_COMPAT_5_2", "LUA_COMPAT_5_1")
                if is_plat("linux", "bsd") then
                    add_defines("LUA_USE_LINUX")
                    add_defines("LUA_DL_DLOPEN")
                elseif is_plat("macosx") then
                    add_defines("LUA_USE_MACOSX")
                    add_defines("LUA_DL_DYLD")
                elseif is_plat("windows") then
                    -- Lua already detects Windows and sets according defines
                    if is_kind("shared") then
                        add_defines("LUA_BUILD_AS_DLL", {public = true})
                    end
                end

            target("lua")
                set_kind("binary")
                add_files(sourcedir .. "lua.c")
                add_deps("lualib")
                if not is_plat("windows") then
                    add_syslinks("dl")
                end

            --##can not exec success
            --target("luac")
            --    set_kind("binary")
            --    add_files(sourcedir .. "luac.c")
            --    add_deps("lualib")
            --    if not is_plat("windows") then
            --        add_syslinks("dl")
            --    end
        ]], sourcedir))

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if is_plat(os.host()) then
            os.vrun("lua -e \"print('hello xmake!')\"")
        end
        assert(package:has_cfuncs("lua_getinfo", {includes = "lua.h"}))
    end)
