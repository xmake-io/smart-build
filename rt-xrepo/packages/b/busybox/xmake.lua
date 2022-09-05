package("busybox")
    set_homepage("https://busybox.net/")
    set_description("A powerful, efficient, lightweight, embeddable scripting language.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/busybox-$(version).tar.bz2")

    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "1-ash.patch"), "6c0927d2217dba7c8bba03bef7a99bef2a448d9a5c6547c435f38f42f7b74844")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "2-uname.patch"), "e585c27ede49ae9ebb329a1f9a45a4378b0db1ec91b02cb0a20a614431486d58")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "3-patch.patch"), "2da45f5598a634660da1a58dbd8067a9c45346de6ee0fc3609200919af67038a")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "5-ftpd.patch"), "3bce40f040df5c4a49e88da3ea5466e1bc9cd866818ec7fc131573547636466d")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "6-zcat.patch"), "0bb5240184768f4fa27d3c63ae619eda73b7a540a2ff6d388b5e205eb135300a")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "7-ftpd.patch"), "6e036cb5e8a8ce2704920c42685d4757d56ca5f78c6d842533c8d263a853c22b")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "8-ftpd-ls-cd.patch"), "4ff8c3002edac7f4601fd490781c5e7d66b71fd529cf327a6e95354bccfe2145")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "9-ls.patch"), "fb38d855575a22faffec8d08dd6ec59b5a18a47e7e3be9473ac4c08b984e8a03")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "10-ls.patch"), "27474a70ee6e37ab84388e8ac71abc2906fdda5b4aaa725df8333dbacb380b3a")
    add_patches("1.32.0", path.join(os.scriptdir(), "patches", "1.32.0", "11-bzip2.patch"), "e75fb4f312f812bef4c07cb104c846ecd8c7c5ef892ee07d838a7be535357c5f")

    add_versions("1.32.0", "c35d87f1d04b2b153d33c275c2632e40d388a88f19a9e71727e0bbbff51fe689")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)
   
    on_install("cross", "linux", "macosx", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end 

        local cmd = string.format("cp -f  %s %s", path.join(os.scriptdir(), ".config"), "$(curdir)/.config")
        os.run(cmd)

        if is_arch("arm") then
            io.gsub(".config", "\nCONFIG_CROSS_COMPILER_PREFIX=\"\"\n", "\nCONFIG_CROSS_COMPILER_PREFIX=" .. "\"arm-linux-musleabi-\"\n")
        else 
            io.gsub(".config", "\nCONFIG_CROSS_COMPILER_PREFIX=\"\"\n", "\nCONFIG_CROSS_COMPILER_PREFIX=" .. "\"aarch64-linux-musleabi-\"\n")
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        package:config_set("pic", false)
        import("package.tools.make").make(package, buildenvs)
        os.cp("busybox", "$(projectdir)/../root/bin/busybox.elf")
    end)

    on_test(function (package)
        assert(os.isfile("$(projectdir)/../root/bin/busybox.elf"))
    end)
