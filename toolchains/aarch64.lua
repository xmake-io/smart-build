toolchain("aarch64-linux-musleabi")
    set_kind("standalone")
    set_sdkdir("$(projectdir)../../tools/gnu_gcc/aarch64-linux-musleabi_for_x86_64-pc-linux-gnu")
    on_load(function(toolchain)

	os.setenv("PROJ_DIR", os.projectdir())  --For lua embed build script
        toolchain:load_cross_toolchain()
        toolchain:set("toolset", "cc", "aarch64-linux-musleabi-gcc")
	    -- add flags for arch
        toolchain:add("cxflags", "-march=armv8-a -D__RTTHREAD__ -O0 -g -gdwarf-2 -Wall -n --static", {force = true})                                           
    end)

toolchain_end()
