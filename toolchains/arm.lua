toolchain("arm-linux-musleabi")
    set_kind("standalone")
    set_sdkdir("$(projectdir)/../../tools/gnu_gcc/arm-linux-musleabi_for_x86_64-pc-linux-gnu")
    on_load(function(toolchain)

	os.setenv("PROJ_DIR", os.projectdir())  --For lua embed build script
        toolchain:load_cross_toolchain()
	    -- add flags for arch
        toolchain:add("cxflags", "-march=armv7-a -marm -msoft-float -D__RTTHREAD__ -g -gdwarf-2 -Wall -n --static", {force = true})   
    end)
toolchain_end()
