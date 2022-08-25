package("wget")

    set_homepage("https://www.gnu.org/software/wget/")
    set_description("A free software package for retrieving files using HTTP, HTTPS, FTP and FTPS.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/wget-$(version).tar.gz")

    add_versions("1.20", "8a057925c74c059d9e37de63a63b450da66c5c1c8cef869a6df420b3bb45a0cf")

    add_patches("1.20", path.join(os.scriptdir(), "patches", "1.20", "1-localtime.patch"), "9cb89115a362987dd515c324233b5f012ba106ae3aa76f1f1472bd6785369452")
    add_patches("1.20", path.join(os.scriptdir(), "patches", "1.20", "2-ftp.patch"), "8023be903c71ff0fb57b7957cfa988dcb408f0db6155b9af0d19d442910dfa63")
    add_patches("1.20", path.join(os.scriptdir(), "patches", "1.20", "3-pcre2.patch"), "b1b6d7b0d512f008341d06369039ddedd090e50d1f5361e3f7fd057a48d90473")
    add_patches("1.20", path.join(os.scriptdir(), "patches", "1.20", "4-skip-openssl-check.patch"), "7e1c2d018a2b152844b665a40bca8365ebf60139b39edbeebc757236d5e1a512")

    add_deps("zlib", "openssl", "pcre")

    on_install("cross", function (package)
 
        local CROSS_COMPILE = "arm-linux-musleabi"
        local configs = {"--prefix=" .. package:installdir(), "--target=" .. CROSS_COMPILE, "--host=" .. CROSS_COMPILE}
        local buildenvs = import("package.tools.autoconf").buildenvs(package)

        table.insert(configs, "--build=i686-pc-linux-gnu")
        table.insert(configs, "--with-ssl=openssl")
        table.insert(configs, "--with-openssl")
        table.insert(configs, "--with-zlib")
        table.insert(configs, "--enable-debug")
        table.insert(configs, "--disable-threads") 
        local packagedeps = {"zlib", "openssl", "pcre"}
        import("package.tools.autoconf").install(package, configs, {packagedeps = packagedeps})

        os.cp(path.join(os.scriptdir(), "etc", "hosts"), package:installdir("etc"))
        os.cp(path.join(os.scriptdir(), "etc", "resolv.conf"), package:installdir("etc"))

    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir("bin"), "wget")))
    end)
