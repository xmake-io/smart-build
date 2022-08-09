package("quickjs")
    set_homepage("https://bellard.org/quickjs/")
    set_description("A small and embeddable Javascript engine.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/quickjs-$(version).tar.xz")

    add_versions("2020-11-08", "2e9d63dab390a95ed365238f21d8e9069187f7ed195782027f0ab311bb64187b")

    add_patches("2020-11-08", path.join(os.scriptdir(), "patches", "2020-11-08", "1-quickjs-makefile.patch"), "72b5904c052c664e949e99475a94e1404c81a8363c970e40a03a05ef98c5aace")
    add_patches("2020-11-08", path.join(os.scriptdir(), "patches", "2020-11-08", "2-os-platform.patch"), "70c873df0210cfc3254c88ab95afa8bcc1d207d244fcf1d20fb25eb199b14d30")

    on_install("linux", function (package)
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            target("quickjs")
                set_kind("static")
                add_files("quickjs*.c", "cutils.c", "lib*.c", "quickjs-libc.c")
                add_headerfiles("quickjs-libc.h")
                add_headerfiles("quickjs.h")
                add_installfiles("*.js", {prefixdir = "share"})
                add_defines("CONFIG_VERSION=\"%s\"", "_GNU_SOURCE")
                add_defines("CONFIG_BIGNUM")
                if is_plat("windows", "mingw") then
                    add_defines("__USE_MINGW_ANSI_STDIO")
                end
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
