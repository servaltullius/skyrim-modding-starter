cmake_minimum_required(VERSION 3.28)

# The preset reads SKSE_BUILD_ROOT, VCPKG_ROOT and VCPKG_VISUAL_STUDIO_PATH, which build.cmd sets.
# Configuring from an IDE ("Open Folder" in Visual Studio, VS Code CMake Tools) without them puts the build
# folder at the drive root and loses the vcpkg toolchain, so stop here with a clear message instead.
foreach(_required_env IN ITEMS SKSE_BUILD_ROOT VCPKG_ROOT VCPKG_VISUAL_STUDIO_PATH)
    if("$ENV{${_required_env}}" STREQUAL "")
        message(FATAL_ERROR
            "${_required_env} is not set. Build this template by running build.cmd in its folder, "
            "not by configuring it from an IDE. See skse-template/README.md.")
    endif()
endforeach()

# Plugin name and version. When you rename the plugin, change the name here AND "name" in vcpkg.json.
# The name becomes the DLL name (MyPlugin.dll) and the log file name (MyPlugin.log).
project(MyPlugin VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(PLUGIN_OUTPUT_ROOT "${CMAKE_BINARY_DIR}/.." CACHE PATH "Where package/ and the release zip are written")
set(DEPLOY_DIR "" CACHE PATH "Optional MO2 mod folder: after each build the DLL is copied to <DEPLOY_DIR>/SKSE/Plugins")
set(PACKAGE_DIR "${PLUGIN_OUTPUT_ROOT}/package")

# DEPLOY_DIR must be a mod folder, never the game's own folders: the copy is done by CMake, so no AI
# permission rule stands in its way.
if(DEPLOY_DIR)
    file(TO_CMAKE_PATH "${DEPLOY_DIR}" _deploy_path)
    string(TOLOWER "${_deploy_path}" _deploy_lower)
    get_filename_component(_deploy_name "${_deploy_path}" NAME)
    get_filename_component(_deploy_parent "${_deploy_path}" DIRECTORY)
    get_filename_component(_deploy_parent_name "${_deploy_parent}" NAME)
    string(TOLOWER "${_deploy_name}" _deploy_name_lower)
    string(TOLOWER "${_deploy_parent_name}" _deploy_parent_lower)
    if(_deploy_lower MATCHES "^[a-z]:/?$"
       OR _deploy_name_lower STREQUAL "data"
       OR _deploy_lower MATCHES "/stock game(/|$)"
       OR _deploy_lower MATCHES "/steamapps/common/")
        message(FATAL_ERROR
            "DEPLOY_DIR (${DEPLOY_DIR}) looks like a drive root, a game folder or a Data folder. "
            "Point it at an MO2 mod folder, e.g. <MO2>/mods/MyPlugin.")
    endif()
    if(NOT _deploy_parent_lower STREQUAL "mods")
        message(WARNING
            "DEPLOY_DIR (${DEPLOY_DIR}) is not directly inside a folder named 'mods'. "
            "Make sure it is the MO2 mod folder you meant; each build overwrites the DLL there.")
    endif()
endif()

find_package(CommonLibSSE CONFIG REQUIRED)

add_commonlibsse_plugin(${PROJECT_NAME}
    SOURCES
        src/main.cpp
)
target_precompile_headers(${PROJECT_NAME} PRIVATE src/PCH.h)
target_include_directories(${PROJECT_NAME} PRIVATE src)

# Keep build-machine paths (which can contain your Windows user name) out of the DLL:
# __FILE__ / std::source_location strings become relative. No trailing backslash, it would escape the quote.
file(TO_NATIVE_PATH "${CMAKE_SOURCE_DIR}" PLUGIN_SOURCE_PREFIX)
file(TO_NATIVE_PATH "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include" PLUGIN_VCPKG_INCLUDE_PREFIX)
target_compile_options(${PROJECT_NAME} PRIVATE
    "/d1trimfile:${PLUGIN_SOURCE_PREFIX}"
    "/d1trimfile:${PLUGIN_VCPKG_INCLUDE_PREFIX}"
)

# package/: the layout of an MO2 mod folder. Built as real outputs, so a deleted or stale copy is
# rebuilt on the next build even when the DLL itself did not change.
set(PLUGIN_PACKAGED_DLL "${PACKAGE_DIR}/SKSE/Plugins/${PROJECT_NAME}.dll")
add_custom_command(
    OUTPUT "${PLUGIN_PACKAGED_DLL}"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PACKAGE_DIR}/SKSE/Plugins"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "$<TARGET_FILE:${PROJECT_NAME}>" "${PLUGIN_PACKAGED_DLL}"
    DEPENDS ${PROJECT_NAME}
    COMMENT "Copying ${PROJECT_NAME}.dll to package/SKSE/Plugins"
    VERBATIM
)

# The DLL statically links CommonLibSSE-NG, spdlog, fmt and others; their licences ask that the notices go
# with the binary. Copy every vcpkg copyright file of this build into package/<PluginName>-licenses.
set(PLUGIN_LICENSE_DIR_NAME "${PROJECT_NAME}-licenses")
file(GLOB PLUGIN_COPYRIGHT_FILES "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/*/copyright")
set(PLUGIN_LICENSE_OUTPUTS "")
foreach(_copyright IN LISTS PLUGIN_COPYRIGHT_FILES)
    get_filename_component(_package_dir "${_copyright}" DIRECTORY)
    get_filename_component(_package_name "${_package_dir}" NAME)
    if(_package_name MATCHES "^vcpkg-")
        continue()
    endif()
    set(_license_output "${PACKAGE_DIR}/${PLUGIN_LICENSE_DIR_NAME}/${_package_name}.txt")
    add_custom_command(
        OUTPUT "${_license_output}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PACKAGE_DIR}/${PLUGIN_LICENSE_DIR_NAME}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${_copyright}" "${_license_output}"
        DEPENDS "${_copyright}"
        VERBATIM
    )
    list(APPEND PLUGIN_LICENSE_OUTPUTS "${_license_output}")
endforeach()

add_custom_target(plugin_package ALL DEPENDS "${PLUGIN_PACKAGED_DLL}" ${PLUGIN_LICENSE_OUTPUTS})

# Optional: also copy the DLL straight into an MO2 mod folder, so a build is ready to test in the game.
if(DEPLOY_DIR)
    set(PLUGIN_DEPLOYED_DLL "${DEPLOY_DIR}/SKSE/Plugins/${PROJECT_NAME}.dll")
    add_custom_command(
        OUTPUT "${PLUGIN_DEPLOYED_DLL}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${DEPLOY_DIR}/SKSE/Plugins"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "$<TARGET_FILE:${PROJECT_NAME}>" "${PLUGIN_DEPLOYED_DLL}"
        DEPENDS ${PROJECT_NAME}
        COMMENT "Copying ${PROJECT_NAME}.dll to DEPLOY_DIR"
        VERBATIM
    )
    add_custom_target(plugin_deploy ALL DEPENDS "${PLUGIN_DEPLOYED_DLL}")
endif()

# Release zip for upload: the DLL in the Data layout plus the licence notices. Written to a temporary
# file first, so a failed run does not delete the previous zip.
set(PLUGIN_ZIP "${PLUGIN_OUTPUT_ROOT}/${PROJECT_NAME}-${PROJECT_VERSION}.zip")
set(PLUGIN_ZIP_ITEMS "SKSE/Plugins/${PROJECT_NAME}.dll")
if(PLUGIN_LICENSE_OUTPUTS)
    list(APPEND PLUGIN_ZIP_ITEMS "${PLUGIN_LICENSE_DIR_NAME}")
endif()
add_custom_target(release_zip
    COMMAND ${CMAKE_COMMAND} -E rm -f "${PLUGIN_ZIP}.partial"
    COMMAND ${CMAKE_COMMAND} -E chdir "${PACKAGE_DIR}"
        ${CMAKE_COMMAND} -E tar cf "${PLUGIN_ZIP}.partial" --format=zip ${PLUGIN_ZIP_ITEMS}
    COMMAND ${CMAKE_COMMAND} -E rename "${PLUGIN_ZIP}.partial" "${PLUGIN_ZIP}"
    COMMENT "Writing ${PROJECT_NAME}-${PROJECT_VERSION}.zip"
    VERBATIM
)
add_dependencies(release_zip plugin_package)
