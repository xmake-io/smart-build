toolchain("arm-linux-musleabi")
    set_kind("standalone")
    set_description("Compile for the given platform")
    set_sdkdir("$(projectdir)/../../tools/gnu_gcc/arm-linux-musleabi_for_x86_64-pc-linux-gnu")
    on_load(function(toolchain)
    os.setenv("PROJ_DIR", os.projectdir())  --For lua embed build script
    toolchain:load_cross_toolchain()
        if is_arch("arm")    then
            print("hello")
        end
    -- add flags for arch
    toolchain:add("cxflags",    "-march=armv7-a -marm -msoft-float -D__RTTHREAD__ -Wall -n --static", {force = true})                                              
    toolchain:add("ldflags",    "-march=armv7-a -marm -msoft-float -D__RTTHREAD__ -Wall -n --static", {force = true})  
    toolchain:add("ldflags",    "-T $(projectdir)/../linker_scripts/arm/cortex-a/link.lds", {force = true})

    if not is_config("pkg_searchdirs", "dropbear") then
        toolchain:add("ldflags",    "-L$(projectdir)/../sdk/rt-thread/lib/arm/cortex-a -Wl,--whole-archive -lrtthread -Wl,--no-whole-archive", {force = true})
    end

    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/include", {force = true})
    toolchain:add("includedirs", "$(projectdir)/../", {force = true})
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/include/libc", {force = true})
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/dfs", {force = true})
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/drivers", {force = true})
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/drivers/include/drivers", {force = true})
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/finsh", {force = true})
    toolchain:add("includedirs", "$(projectdir)/../sdk/rt-thread/components/net", {force = true})

    if is_mode("debug") then
        toolchain:add("cxflags", "-g -gdwarf-2", {force = true})
    end

    if is_mode("release") then
        toolchain:add("cxflags", "-O2", {force = true})
    end

    end)

toolchain_end()
