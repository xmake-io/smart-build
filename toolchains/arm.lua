toolchain("arm-linux-musleabi")
    set_kind("standalone")
    set_sdkdir("$(projectdir)/../../tools/gnu_gcc/arm-linux-musleabi_for_x86_64-pc-linux-gnu")
    on_load(function(toolchain)
    os.setenv("PROJ_DIR", os.projectdir())  --For lua embed build script
    toolchain:load_cross_toolchain()
    toolchain:set("toolset", "cxx", "arm-linux-musleabi-g++")
    toolchain:set("toolset", "strip", "arm-linux-musleabi-stricp")
    -- add flags for arch
    toolchain:add("cxflags", "-march=armv7-a -marm -msoft-float -D__RTTHREAD__  -Wall -n --static", {force = true})                                              
    toolchain:add("ldflags", "-march=armv7-a -marm -msoft-float -D__RTTHREAD__ -Wall -n --static", {force = true})  
    toolchain:add("ldflags", "-T $(projectdir)/../linker_scripts/arm/cortex-a/link.lds", {force = true})
    toolchain:add("ldflags", "-L$(projectdir)/../sdk/rt-thread/lib/arm/cortex-a -Wl,--whole-archive -lrtthread -Wl,--no-whole-archive", {force = true})
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/include")
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/dfs")
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/drivers")
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/finsh")
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/net")
    toolchain:add("linkdirs", "$(projectdir)/../sdk/rt-thread/lib/arm/cortex-a")

    if is_mode("debug") then
        toolchain:add("cxflags", "-g -gdwarf-2", {force = true})
    end
    -- 如果是release或者profile模式
        -- 如果是release模式
    if is_mode("release") then
        toolchain:add("cxflags", "-O2", {force = true})
    end

    end)
toolchain_end()
