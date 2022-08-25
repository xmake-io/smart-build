package("openssl")

    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/openssl-$(version).tar.gz")

    add_versions("1.1.1i", "e8be6a35fe41d10603c3cc635e93289ed00bf34b79671a3a4de64fcee00d5242")

    add_patches("1.1.1i", path.join(os.scriptdir(), "patches", "1.1.1i", "1-openssl.patch"), "3df10a4c3826dfe77da22ef33dfb950c8a7df5e6d2bef8abc95ac10c89bf5ef8")

    add_links("ssl", "crypto")

    on_install("cross", "linux", function (package)

        local target = "linux-generic32"
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        buildenvs.CFLAGS = path.join(buildenvs.CFLAGS, " -I", path.join(os.scriptdir(), "include"))
        print(buildenvs.CFLAGS)
        os.vrun("./Configure " ..  target .. " -DOPENSSL_NO_HEARTBEATS no-threads -no-shared" .. " --prefix=" .. package:installdir())
        import("package.tools.make").install(package, buildenvs)
	    os.cp(os.scriptdir("") .. "/include/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
