package("quickjs")
    set_homepage("https://bellard.org/quickjs/")
    set_description("A small and embeddable Javascript engine.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/quickjs-$(version).tar.xz")

    add_versions("2020-11-08", "2e9d63dab390a95ed365238f21d8e9069187f7ed195782027f0ab311bb64187b")

    add_patches("2020-11-08", path.join(os.scriptdir(), "patches", "2020-11-08", "2-os-platform.patch"), "70c873df0210cfc3254c88ab95afa8bcc1d207d244fcf1d20fb25eb199b14d30")

    if not is_plat("windows", "mingw") then
        add_syslinks("dl", "m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("linux", "cross", function (package)
        io.writefile("xmake.lua", ([[
            add_rules("mode.release", "mode.debug")
            target("qjs")
                set_enabled(true)
                set_kind("binary")
                add_files("qjs.c", "quickjs.c", "qjscalc.c", "repl.c", "libregexp.c", "libunicode.c", "libunicode.c", "cutils.c", "quickjs-libc.c", "libbf.c")
                add_headerfiles("quickjs-libc.h", "quickjs.h")
                add_defines("CONFIG_VERSION=\"%s\"", "_GNU_SOURCE", "CONFIG_BIGNUM")
                if is_plat("linux", "macosx", "iphoneos", "cross") then
                    add_syslinks("pthread", "dl", "m")
                end
        ]]):format(package:version_str()))
        package:config_set("pic", false) 

        local cmd = string.format("cp -f  %s %s", path.join(os.scriptdir(), "host-qjsc"), "$(curdir)/host-qjsc")
        os.run(cmd)
        os.exec("./host-qjsc -c -o repl.c -m repl.js")
        os.exec("./host-qjsc -c -o qjscalc.c -m qjscalc.js")

        import("package.tools.autoconf").buildenvs(package)  
        import("package.tools.xmake").install(package)
    end)
