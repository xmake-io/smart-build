toolchain("aarch64-linux-musleabi")
    set_kind("standalone")
    set_sdkdir("$(projectdir)/../../tools/gnu_gcc/aarch64-linux-musleabi_for_x86_64-pc-linux-gnu")
    on_load(function(toolchain)

	os.setenv("PROJ_DIR", os.projectdir())  --For lua embed build script
        toolchain:load_cross_toolchain()
        toolchain:set("toolset", "cxx", "arm-linux-musleabi-g++")
	    -- add flags for aarch64
        toolchain:add("cxflags",     "-march=armv8-a -D__RTTHREAD__  -Wall -n --static", {force = true})                                             
        toolchain:add("ldflags",     "-march=armv8-a -D__RTTHREAD__  -Wall -n --static", {force = true})  
        toolchain:add("ldflags",     "-T $(projectdir)/../linker_scripts/aarch64/link.lds", {force = true})
        if not is_config("pkg_searchdirs", "dropbear") then
            toolchain:add("ldflags",     "-L$(projectdir)/../sdk/rt-thread/lib/aarch64/cortex-a -Wl,--whole-archive -lrtthread -Wl,--no-whole-archive", {force = true})
        end
        toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/include", {force = true})
        toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/dfs", {force = true})
        toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/drivers", {force = true})
        toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/finsh", {force = true})
        toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/net", {force = true})
        toolchain:add("linkdirs",    "$(projectdir)/../sdk/rt-thread/lib/aarch64", {force = true})    
        
        if is_config("kind", "debug") then
            toolchain:add("cxflags", "-g -gdwarf-2", {force = true})
        else
            toolchain:add("cxflags", "-O2", {force = true})
        end

    end)

toolchain_end()
