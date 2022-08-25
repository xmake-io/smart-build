package("quickjs")
    set_homepage("https://bellard.org/quickjs/")
    set_description("A small and embeddable Javascript engine.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/quickjs-$(version).tar.xz")

    add_versions("2020-11-08", "2e9d63dab390a95ed365238f21d8e9069187f7ed195782027f0ab311bb64187b")

    add_patches("2020-11-08", path.join(os.scriptdir(), "patches", "2020-11-08", "1-quickjs-makefile.patch"), "72b5904c052c664e949e99475a94e1404c81a8363c970e40a03a05ef98c5aace")
    add_patches("2020-11-08", path.join(os.scriptdir(), "patches", "2020-11-08", "2-os-platform.patch"), "70c873df0210cfc3254c88ab95afa8bcc1d207d244fcf1d20fb25eb199b14d30")

    if not is_plat("windows", "mingw") then
        add_syslinks("dl", "m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("linux", "cross", function (package)
        io.writefile("xmake.lua", ([[
            add_rules("mode.release")
            target("host-qjs")
                set_enabled(true)
                set_kind("binary")
                set_toolchains("gcc")
                set_toolset("ld", "gcc")
                add_cflags(" -g -Wall -O2 -c -flto -Wno-array-bounds -Wno-format-truncation")
                add_ldflags(" -g -flto ")
                add_files("qjs.c", "quickjs.c", "libregexp.c", "libunicode.c", "cutils.c", "quickjs-libc.c", "libbf.c")
                if is_plat("linux", "macosx", "iphoneos", "cross") then
                    add_syslinks("pthread", "dl", "m")
                end
                add_defines("CONFIG_VERSION=\"%s\"", "_GNU_SOURCE", "CONFIG_BIGNUM")

        ]]):format(package:version_str()))
        package:config_set("pic", false)   
        import("package.tools.xmake").install(package)
    end)

    on_install("linux", "cross", function (package)
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            target("host-qjs")
                set_enabled(true)
                set_kind("binary")
                set_basename("host-qjs")
                add_files("qjs.c", "quickjs.c", "libregexp.c", "libunicode.c", "libunicode.c", "cutils.c", "quickjs-libc.c", "libbf.c")
                add_headerfiles("quickjs-libc.h", "quickjs.h")
                add_defines("CONFIG_VERSION=\"%s\"", "_GNU_SOURCE", "CONFIG_BIGNUM")

        ]]):format(package:version_str()))
        local configs = {}
        package:config_set("pic", false)   
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.autoconf").buildenvs(package) 
        import("package.tools.xmake").install(package, configs)
    end)

    on_install("windows", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.autoconf").buildenvs(package)
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("JS_NewRuntime", {includes = "quickjs.h"}))
    end)
