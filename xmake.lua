includes("scripts/platform.lua")
includes("scripts/packages.lua")
includes("scripts/buildoption.lua")
includes("toolchains/arm.lua")
includes("toolchains/aarch64.lua")

set_xmakever("2.6.9")
set_version("0.0.1")

add_repositories("rt-xrepo $(projectdir)/rt-xrepo")

-- 工具链
if is_arch("arm", "armv7", "armv7s", "armv7-a") then
    set_toolchains("arm-linux-musleabi")
elseif is_arch("aarch64") then
    set_toolchains("aarch64-linux-musleabi")
end

-- 设置目标文件的扩展名
set_extension(".elf")

-- 设置警告级别
set_warnings("all", "error")

-- 设置优化级别
set_optimize("fastest")

-- 设置c代码标准：c99， c++代码标准：c++11
set_languages("c99", "cxx11")

-- -- 设置生成目标文件目录 set_targetdir

task("buildroot")
    on_run("scripts.buildroot")
    set_menu {  usage = "xmake buildroot [options] [arguments]",
                description = "Generate buildroot for rt-smart.",
                options = {
                    {nil, "menuconfig", "k", nil, "config and build project."},
                    {nil, "clean",      "k", nil, "clean build dir."},
                    {nil, "distclean",  "k", nil, "clean build and all installed pkg."}
		        }
             }
