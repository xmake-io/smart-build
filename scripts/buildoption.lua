option("toolchain")
    set_default("ELF")
    set_category("Build options")
    set_description("Number of jobs to run simultaneously (0 for auto)")
    set_values("ELF")
option_end()

option("level")
    set_default("optimization level 0")
    set_category("Build options")
    set_description("gcc optimization level")
    set_values("optimization level 0", "optimization level 1")
option_end()

