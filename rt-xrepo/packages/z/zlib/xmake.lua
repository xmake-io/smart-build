package("zlib")
    set_homepage("http://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")
    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/zlib-$(version).tar.gz")
    add_versions("1.2.8", "36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d")

    on_install("windows", function (package)
        io.gsub("win32/Makefile.msc", "%-MD", "-" .. package:config("vs_runtime"))
        import("package.tools.nmake").build(package, {"-f", "win32\\Makefile.msc", "zlib.lib"})
        os.cp("zlib.lib", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
    end)

    on_install("cross", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        import("package.tools.autoconf").configure(package, {host = ""})
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        buildenvs.CFLAGS = path.join(buildenvs.CFLAGS, " --static")
        buildenvs.LDFLAGS = path.join(buildenvs.LDFLAGS, " --static")
        import("package.tools.make").install(package, buildenvs)

    end)
