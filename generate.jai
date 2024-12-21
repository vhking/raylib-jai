#import "Basic";
#import "BuildCpp";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "File_Utilities";

AT_COMPILE_TIME :: true;
SOURCE_PATH :: "source";


MODULE_DIR :: "modules/raylib";

#if AT_COMPILE_TIME {
    #run,stallable {
        set_build_options_dc(.{do_output=false});
        options := get_build_options();
        args := options.compile_time_command_line;
        if !generate_bindings(args, options.minimum_os_version) {
            compiler_set_workspace_status(.FAILED);
        }
    }
} else {
    #import "System";

    main :: () {
        set_working_directory(path_strip_filename(get_path_of_running_executable()));
        if !generate_bindings(get_command_line_arguments(), #run get_build_options().minimum_os_version) {
            exit(1);
        }
    }
}

generate_bindings :: (args: [] string, minimum_os_version: type_of(Build_Options.minimum_os_version)) -> bool {
    os_target :=  OS;
    cpu_target := CPU;

    compile_debug  := array_find(args, "-debug");
    // TODO: compile from source
    
    lib_directory: string;
    lib_name: string;
    
    if os_target == {
        case .WINDOWS;
            lib_directory = "windows";
	    lib_name =      "raylib";
        case .LINUX;
            lib_directory = "linux";
	    lib_name      = "libraylib";
        case;
            assert(false);
    }

    options: Generate_Bindings_Options;
    options.os = os_target;
    options.cpu = cpu_target;
    {
        using options;

        array_add(*libpaths, lib_directory);
        array_add(*libnames, lib_name);
        array_add(*source_files, tprint("%/raylib.h", SOURCE_PATH));
        array_add(*source_files, tprint("%/raymath.h", SOURCE_PATH));
        array_add(*source_files, tprint("%/rlgl.h", SOURCE_PATH));

        footer = tprint(FOOTER_TEMPLATE, lib_name);
        header = tprint(HEADER_TEMPLATE, lib_name);

        generate_library_declarations =       false;
        auto_detect_enum_prefixes =           false;
        log_stripped_declarations =           false;
        generate_compile_time_struct_checks = true;
        alias_original_enum_names =           false;
        c_enum_emulation =                    false;
        generate_library_declarations =       false;
        
    }
     
    copy_directory(lib_directory, tprint("%/%",MODULE_DIR, lib_directory));  
    output_filename := tprint("%/bindings.jai", MODULE_DIR);
    
    return generate_bindings(options, output_filename);
}

// Add definitions for things that are missing in the { binding.jai } header.
HEADER_TEMPLATE :: #string END
    va_list :: *void;
END

FOOTER_TEMPLATE :: #string END
#if OS == .WINDOWS {
    user32  :: #system_library,link_always "user32";
    gdi32   :: #system_library,link_always "gdi32";
    shell32 :: #system_library,link_always "shell32";
    winmm   :: #system_library,link_always "winmm";
    %1 ::      #library "windows/%1";
} else #if OS == .LINUX {
    %1 :: #library "linux/%1";
    #library,system,link_always "libm";
} else {
    #assert false;
}
END

