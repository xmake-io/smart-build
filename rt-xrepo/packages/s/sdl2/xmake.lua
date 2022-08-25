

package("sdl2")

    set_homepage("https://www.libsdl.org/")
    set_description("Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware via OpenGL and Direct3D.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/SDL2-$(version).tar.gz")

    add_versions("2.0.14", "d8215b571a581be1332d2106f8036fcb03d12a70bae01e20f424976d275432bc")

    add_patches("2.0.14", path.join(os.scriptdir(), "patches", "2.0.14", "3-porting-on-rtt.diff"), "56f04987f181fc8c97e564249124aacb7fbcd3798aa1c3011b71ac773fbfb69e")

    if not is_plat("windows") then
        add_syslinks("dl", "m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("cross", "linux", "macosx", function (package)

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end  

        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        os.exec("./autogen.sh")

        if is_arch("arm") then
            table.insert(configs, "--host=arm-linux-musleabi")
        else 
            table.insert(configs, "--host=aarch64-linux-musleabi")
        end
        table.insert(configs, "--enable-static")
        table.insert(configs, "--build=i686-pc-linux-gnu")
        table.insert(configs, "--enable-joystick-virtual=no")
        table.insert(configs, "--enable-render-d3d=no")
        table.insert(configs, "--enable-sdl-dlopen=no")
        table.insert(configs, "--enable-joystick=no")
        table.insert(configs, "--enable-joystick-mfi=no")
        table.insert(configs, "--enable-hidapi=no")
        table.insert(configs, "--enable-hidapi-libusb=no")
        table.insert(configs, "--enable-shared=no")
        table.insert(configs, "--enable-threads=no")
        table.insert(configs, "--enable-3dnow=no")
        table.insert(configs, "--enable-jack-shared=no")
        table.insert(configs, "--enable-pulseaudio-shared=no")
        table.insert(configs, "--enable-pulseaudio=no")
        table.insert(configs, "--enable-cpuinfo=no")
        table.insert(configs, "--enable-video-directfb")
        table.insert(configs, "--enable-directfb-shared=no")

        import("package.tools.autoconf").install(package, configs)

        os.cp("build/.libs/libSDL2.a", "$(projectdir)/../sdk/lib/$(arch)/cortex-a")
        os.cp("include/*.h", "$(projectdir)/../sdk/include/sdl/")
    end)

