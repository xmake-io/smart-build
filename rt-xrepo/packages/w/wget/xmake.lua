package("wget")

    set_homepage("https://www.gnu.org/software/wget/")
    set_description("A free software package for retrieving files using HTTP, HTTPS, FTP and FTPS.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/wget-$(version).tar.gz")

    add_versions("1.20", "89e0cc7563da4af74b290924a0115e884a61023f")

    add_patches("1.20", path.join(os.scriptdir(), "patches", "1.20", "1-localtime.patch"), "9cb89115a362987dd515c324233b5f012ba106ae3aa76f1f1472bd6785369452")
    add_patches("1.20", path.join(os.scriptdir(), "patches", "1.20", "2-ftp.patch"), "8023be903c71ff0fb57b7957cfa988dcb408f0db6155b9af0d19d442910dfa63")
    add_patches("1.20", path.join(os.scriptdir(), "patches", "1.20", "3-pcre2.patch"), "b1b6d7b0d512f008341d06369039ddedd090e50d1f5361e3f7fd057a48d90473")

    add_deps("zlib", "openssl", "pcre")

    on_install("cross", function (package)
	local CROSS_COMPILE="arm-linux-musleabi"
        local configs = {"--prefix=" .. package:installdir(), "--target=" .. CROSS_COMPILE, "--host=" .. CROSS_COMPILE, "--build=i686-pc-linux-gnu", "--with-ssl=openssl", "--with-openssl", "--disable-threads", "--with-zlib"}
	local buildenvs = import("package.tools.autoconf").buildenvs(package)
        buildenvs.CFLAGS = path.join(buildenvs.CFLAGS, " -I", package:dep("zlib"):installdir("include"), " -I", package:dep("openssl"):installdir("include"), " -I", package:dep("pcre"):installdir("include"))
	buildenvs.LDFLAGS = path.join(buildenvs.LDFLAGS, " -L", package:dep("zlib"):installdir("lib"), " -L", package:dep("openssl"):installdir("lib"), " -L", package:dep("pcre"):installdir("lib"))
	os.vrunv("./configure", configs, {envs = buildenvs})
	local makeconfigs = {CFLAGS = buildenvs.CFLAGS, LDFLAGS = buildenvs.LDFLAGS}
	import("package.tools.make").install(package, makeconfigs)
	os.cp(path.join(os.scriptdir(), "etc", "hosts"), package:installdir("etc"))
	os.cp(path.join(os.scriptdir(), "etc", "resolv.conf"), package:installdir("etc"))
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir("bin"), "wget")))
    end)
