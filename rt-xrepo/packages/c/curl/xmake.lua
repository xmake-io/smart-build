package("curl")

    set_homepage("https://curl.se/")
    set_description("A command line tool and library for transferring data with URLs")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/curl-$(version).tar.gz")

    add_versions("7.70.0", "ca2feeb8ef13368ce5d5e5849a5fd5e2dd4755fecf7d8f0cc94000a4206fb8e7")

    add_patches("7.70.0", path.join(os.scriptdir(), "patches", "7.70.0", "1-rtt-console.patch"), "651617be760341e025a9e4d68278f75b60e856d22558f7e89ba3de30aee2bb0b")
    add_patches("7.70.0", path.join(os.scriptdir(), "patches", "7.70.0", "2-set_homedir.patch"), "84df75dd39baa92090f39b17151c7324458d49359e00a5bd4f8602f322e9c1a0")
    add_patches("7.70.0", path.join(os.scriptdir(), "patches", "7.70.0", "3-undef_socketpair_header.patch"), "a438b413a1123781f88d685794c97d1751241cd04307cc40c8acf1a4bbb8de4c")
    add_patches("7.70.0", path.join(os.scriptdir(), "patches", "7.70.0", "4-error.patch"), "3cc37ce12312359a417dc626f04a1c62ca68baab6cbd39ede5029064c604a522")
    add_patches("7.70.0", path.join(os.scriptdir(), "patches", "7.70.0", "5-detail.patch"), "e1fb16411fda176281769e5495d76ec79edd2b8af164286fe5d1662b92a69b1a")

    add_deps("zlib", "openssl")

    on_install("cross", function (package)

        if is_arch("arm") then    
            local CROSS_COMPILE = "arm-linux-musleabi"
        else 
            local CROSS_COMPILE = "aarch64-linux-musleabi"
        end

        local configs = {"--prefix=" .. package:installdir(), "--target=" .. CROSS_COMPILE, "--host=" .. CROSS_COMPILE}
        local buildenvs = import("package.tools.autoconf").buildenvs(package)

        table.insert(configs, "--build=i686-pc-linux-gnu")
        table.insert(configs, "--with-ssl")
        table.insert(configs, "--with-zlib")
        table.insert(configs, "--enable-debug")

        local packagedeps = {"zlib", "openssl"}
        import("package.tools.autoconf").install(package, configs, {packagedeps = packagedeps})
    
    end)

    on_test(function (package)
	    assert(os.isfile(path.join(package:installdir("bin"), "curl")))
    end)
