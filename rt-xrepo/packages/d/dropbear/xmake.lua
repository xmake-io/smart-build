package("dropbear")

    set_homepage("https://matt.ucc.asn.au/dropbear/dropbear.html")
    set_description("Dropbear is a relatively small SSH server and client. It runs on a variety of unix platforms")

    add_urls("https://github.com/liukangcc/dropbear/archive/refs/tags/1.0.tar.gz")

    add_versions("2022.82", "9593ea048f1f839e88b927488091cacff89b37b6a3f032e73d8d34b00d1caa82")

    add_deps("zlib")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("cross", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end  

        local buildenvs = import("package.tools.autoconf").buildenvs(package)

        if is_arch("arm") then
            table.insert(configs, "--host=arm-linux-musleabi")
        else 
            table.insert(configs, "--host=aarch64-linux-musleabi")
        end

        -- table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        -- table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

        -- if package:config("pic") ~= false then
        --     table.insert(configs, "--with-pic")
        -- end

        table.insert(configs, "--enable-debug")
        table.insert(configs, "--disable-utmp")
        table.insert(configs, "--disable-wtmp")
        table.insert(configs, "--disable-lastlog")
        table.insert(configs, "--disable-syslog")

        os.run("chmod 777 ./ifndef_wrapper.sh")
	    import("package.tools.autoconf").install(package, configs, {packagedeps = "zlib"})
 
    end)

