package("uhttpd")

    set_homepage("https://openwrt.org/docs/guide-user/services/webserver/http.uhttpd")
    set_description("A web server written to be an efficient and stable server, suitable for lightweight tasks commonly used with embedded devices")

    add_urls("http://www.wxucr.com/dl/uhttpd-$(version).tar.gz")

    add_versions("2021", "ac80a67853a1997b3433f90787f5c9ab969cc98d8aee710e008d8b627cc7f301")

    add_patches("2021", path.join(os.scriptdir(), "patches", "2021", "1-Makefile-for-xmake.patch"), "db3642020e895fae31e493e7de30c9a665c38af767820028591ddbac14520238")
    add_patches("2021", path.join(os.scriptdir(), "patches", "2021", "2-realpath-for-xmake.patch"), "9427b39aa65648062af93d3ae5d95c56302cd57fdea9450c46dd15d520c44246")

    add_deps("lua", "openssl")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("cross", function (package)
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
	buildenvs.CFLAGS = path.join(buildenvs.CFLAGS, " -I", package:dep("lua"):installdir("include"), " -I", package:dep("openssl"):installdir("include"))
        buildenvs.LDFLAGS = path.join(buildenvs.LDFLAGS, " -L", package:dep("lua"):installdir("lib"), " -L", package:dep("openssl"):installdir("lib"))
	io.gsub("Makefile", "\nprefix=\n", "\nprefix=" .. package:installdir())
	local makeconfigs = {V=1, CFLAGS = buildenvs.CFLAGS, LDFLAGS = buildenvs.LDFLAGS, CXX=buildenvs.CXX}
	import("package.tools.make").install(package, makeconfigs)
    end)

    on_test(function (package)
	assert(os.isfile(path.join(package:installdir("bin"), "uhttpd")))
    end)
