-- Level 1 menu: packages management

-- packages management 
----    Audio and video applications
----    Compressors and decompressors
----    Networking applications
----    Filesystem and flash utilities
----    Interpreter languages and scripting
----    System tools
----    Graphic libraries and applications


-- Networking applications
option("curl") --deps: ssl, zlib
    set_default(false)
    set_showmenu(true)
    set_description("curl")
    set_category("Target packages/Networking applications")
    add_deps("openssl", "zlib")
    after_check(function (option)
        if option:enabled() then
            option:dep("openssl"):enable(true)
            option:dep("zlib"):enable(true)
        end
    end)
option_end()

option("openssl")
    set_default(false)
    set_showmenu(true)
    set_description("openssl")
    set_category("Target packages/Networking applications")
option_end()

option("uhttpd") --deps: lua, ssl
    set_default(false)
    set_showmenu(true)
    set_description("uhttpd")
    set_category("Target packages/Networking applications")
    add_deps("openssl", "lua")
    after_check(function (option)
        if option:enabled() then
            option:dep("openssl"):enable(true)
            option:dep("lua"):enable(true)
        end
    end)
option_end()

option("wget") --deps: ssl, zlib, pcre
    set_default(false)
    set_showmenu(true)
    set_description("wget")
    set_category("Target packages/Networking applications")
    add_deps("openssl", "zlib", "pcre")
    after_check(function (option)
        if option:enabled() then
            option:dep("openssl"):enable(true)
            option:dep("pcre"):enable(true)
            option:dep("zlib"):enable(true)
        end
    end)
option_end()


-- Interpreter languages and scripting
option("quickjs")
    set_default(false)
    set_showmenu(true)
    set_description("quickjs")
    set_category("Target packages/Interpreter languages and scripting")
option_end()

option("lua")
    set_default(false)
    set_showmenu(true)
    set_description("lua")
    set_category("Target packages/Interpreter languages and scripting")
option_end()

-- Compressors and decompressors
option("zlib")
    set_default(false)
    set_showmenu(true)
    set_description("zlib")
    set_category("Target packages/Compressors and decompressors")
option_end()

-- System tools
option("pcre")
    set_default(false)
    set_showmenu(true)
    set_description("pcre")
    set_category("Target packages/System tools")
option_end()

option("busybox")
    set_default(false)
    set_showmenu(true)
    set_description("busybox")
    set_category("Target packages/System tools")
option_end()

option("dropbear")
    set_default(false)
    set_showmenu(true)
    add_deps("busybox")
    set_description("dropbear")
    set_category("Target packages/System tools")
option_end()

-- Graphic libraries and applications
option("sdl2")
    set_default(false)
    set_showmenu(true)
    set_description("sdl2")
    set_category("Target packages/Graphic libraries and applications")
option_end()


local apps = {"lua", "pcre", "zlib", "openssl", "quickjs", "wget", "curl", "uhttpd", "busybox", "dropbear"} --libs ahead

for key, val in pairs(apps) do
    if has_config(val) then
         add_requires(val, {system = false, configs = {}})
    end
end
