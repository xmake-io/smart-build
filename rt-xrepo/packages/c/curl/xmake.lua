package("curl")

    set_homepage("https://curl.se/")
    set_description("A command line tool and library for transferring data with URLs")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/curl-$(version).tar.gz")

    add_versions("7.70.0", "ca2feeb8ef13368ce5d5e5849a5fd5e2dd4755fecf7d8f0cc94000a4206fb8e7")

    add_patches("7.70.0", path.join(os.scriptdir(), "patches", "7.70.0", "1-rtt-console.patch"), "651617be760341e025a9e4d68278f75b60e856d22558f7e89ba3de30aee2bb0b")

    add_deps("zlib", "openssl")

    on_install("cross", function (package)
	local CROSS_COMPILE="arm-linux-musleabi"
    local configs = {"--prefix=" .. package:installdir(), "--target=" .. CROSS_COMPILE, "--host=" .. CROSS_COMPILE, "--build=i686-pc-linux-gnu", "--with-ssl", "--with-zlib"}
	local buildenvs = import("package.tools.autoconf").buildenvs(package)
    buildenvs.CFLAGS = path.join(buildenvs.CFLAGS, " -I", package:dep("zlib"):installdir("include"), " -I", package:dep("openssl"):installdir("include"))
    buildenvs.LIBS = path.join(buildenvs.LDFLAGS, " -static -Wl,--start-group -lc -lgcc -lrtthread -Wl,--end-group")
	buildenvs.LDFLAGS = path.join("-L", package:dep("zlib"):installdir("lib"), " -L", package:dep("openssl"):installdir("lib"))
	os.vrunv("./configure", configs, {envs = buildenvs})
	local makeconfigs = {V=1, CFLAGS = buildenvs.CFLAGS, LDFLAGS = buildenvs.LDFLAGS, LIBS = buildenvs.LIBS}
	import("package.tools.make").install(package, makeconfigs)
    end)

    -- on_test(function (package)
	-- assert(os.isfile(path.join(package:installdir("bin"), "curl")))
    -- end)
