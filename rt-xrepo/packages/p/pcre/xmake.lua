package("pcre")

    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")

    set_urls("http://117.143.63.254:9012/www/rt-smart/packages/pcre-$(version).tar.gz")

    add_versions("8.44", "aecafd4af3bd0f3935721af77b889d9024b2e01d96b58471bd91a3063fb47728")

    on_install("cross", function (package)
	--import("core.base.option")
        local CROSS_COMPILE="arm-linux-musleabi"
	local configs = {"--prefix=" .. package:installdir(), "--target=" .. CROSS_COMPILE, "--host=" .. CROSS_COMPILE, "--build=i686-pc-linux-gnu", "--disable-shared"}
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        os.vrunv("./configure", configs, {envs = buildenvs})
	io.gsub("libtool", "\nlt_ar_flags=\n", "\nlt_ar_flags=cr\n")
	io.gsub("libtool", "\n    prefer_static_libs=no\n", "\n    prefer_static_libs=yes\n")
	--##local makeconfigs = {V=1, CFLAGS = buildenvs.CFLAGS, LDFLAGS = buildenvs.LDFLAGS}
	--##import("package.tools.make").install(package, makeconfigs)
	local argv = {"-j1"}
        table.insert(argv, "V=1")
        table.insert(argv, "CFLAGS=" .. buildenvs.CFLAGS)
        table.insert(argv, "LDFLAGS=" .. buildenvs.LDFLAGS)
	os.vrunv("make", argv)
	os.vrun("make install")
    end)

--     on_test(function (package)
--         local bitwidth = package:config("bitwidth") or "8"
--         local testfunc = string.format("pcre%s_compile", bitwidth ~= "8" and bitwidth or "")
--         assert(package:has_cfuncs(testfunc, {includes = "pcre.h"}))
--     end)
