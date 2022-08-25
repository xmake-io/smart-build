package("dropbear")

    set_homepage("https://matt.ucc.asn.au/dropbear/dropbear.html")
    set_description("Dropbear is a relatively small SSH server and client. It runs on a variety of unix platforms")

    add_urls("https://matt.ucc.asn.au/dropbear/dropbear-$(version).tar.bz2")

    add_versions("2022.82", "3a038d2bbc02bf28bbdd20c012091f741a3ec5cbe460691811d714876aad75d1")

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

        table.insert(configs, "--enable-static")
        table.insert(configs, "--disable-utmp")
        table.insert(configs, "--disable-wtmp")
        table.insert(configs, "--disable-lastlog")
        table.insert(configs, "--disable-syslog")
        package:config_set("pic", false)   
	    import("package.tools.autoconf").install(package, configs, {packagedeps = "zlib"})
 
    end)

