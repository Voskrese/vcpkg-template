cmake_minimum_required(VERSION 3.5)

macro(debug_message)
    if(DEFINED PORT_DEBUG AND PORT_DEBUG)
        message(STATUS "[DEBUG] ${ARGN}")
    endif()
endmacro()

if((NOT DEFINED VCPKG_ROOT_DIR)
    OR (NOT DEFINED DOWNLOADS)
    OR (NOT DEFINED _VCPKG_INSTALLED_DIR)
    OR (NOT DEFINED PACKAGES_DIR)
    OR (NOT DEFINED BUILDTREES_DIR))
    message(FATAL_ERROR [[
        Your vcpkg executable is outdated and is not compatible with the current CMake scripts.
        Please re-build vcpkg by running bootstrap-vcpkg.
    ]])
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(CURRENT_INSTALLED_DIR ${_VCPKG_INSTALLED_DIR}/${TARGET_TRIPLET} CACHE PATH "Location to install final packages")
set(SCRIPTS ${CMAKE_CURRENT_LIST_DIR} CACHE PATH "Location to stored scripts")

if(PORT)
    set(CURRENT_BUILDTREES_DIR ${BUILDTREES_DIR}/${PORT})
    set(CURRENT_PACKAGES_DIR ${PACKAGES_DIR}/${PORT}_${TARGET_TRIPLET})
endif()


if(CMD MATCHES "^BUILD$")
    set(CMAKE_TRIPLET_FILE ${TARGET_TRIPLET_FILE})
    if(NOT EXISTS ${CMAKE_TRIPLET_FILE})
        message(FATAL_ERROR "Unsupported target triplet. Triplet file does not exist: ${CMAKE_TRIPLET_FILE}")
    endif()

    if(NOT DEFINED CURRENT_PORT_DIR)
        message(FATAL_ERROR "CURRENT_PORT_DIR was not defined")
    endif()
    set(TO_CMAKE_PATH "${CURRENT_PORT_DIR}" CURRENT_PORT_DIR)
    if(NOT EXISTS ${CURRENT_PORT_DIR})
        message(FATAL_ERROR "Cannot find port: ${PORT}\n  Directory does not exist: ${CURRENT_PORT_DIR}")
    endif()
    if(NOT EXISTS ${CURRENT_PORT_DIR}/portfile.cmake)
        message(FATAL_ERROR "Port is missing portfile: ${CURRENT_PORT_DIR}/portfile.cmake")
    endif()
    if(NOT EXISTS ${CURRENT_PORT_DIR}/CONTROL AND NOT EXISTS ${CURRENT_PORT_DIR}/vcpkg.json)
        message(FATAL_ERROR "Port is missing control or manifest file: ${CURRENT_PORT_DIR}/{CONTROL,vcpkg.json}")
    endif()

    unset(PACKAGES_DIR)
    unset(BUILDTREES_DIR)

    if(EXISTS ${CURRENT_PACKAGES_DIR})
        file(GLOB FILES_IN_CURRENT_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}/*")
        if(FILES_IN_CURRENT_PACKAGES_DIR)
            file(REMOVE_RECURSE ${FILES_IN_CURRENT_PACKAGES_DIR})
            file(GLOB FILES_IN_CURRENT_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}/*")
            if(FILES_IN_CURRENT_PACKAGES_DIR)
                message(FATAL_ERROR "Unable to empty directory: ${CURRENT_PACKAGES_DIR}\n  Files are likely in use.")
            endif()
        endif()
    endif()
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR} ${CURRENT_PACKAGES_DIR})

    include(${CMAKE_TRIPLET_FILE})

    if (DEFINED VCPKG_ENV_OVERRIDES_FILE)
        include(${VCPKG_ENV_OVERRIDES_FILE})
    endif()

    if (DEFINED VCPKG_PORT_TOOLCHAINS)
        foreach(VCPKG_PORT_TOOLCHAIN ${VCPKG_PORT_TOOLCHAINS})
            include(${VCPKG_PORT_TOOLCHAIN})
        endforeach()
    endif()

    if (DEFINED VCPKG_PORT_CONFIGS)
        foreach(VCPKG_PORT_CONFIG ${VCPKG_PORT_CONFIGS})
            include(${VCPKG_PORT_CONFIG})
        endforeach()
    endif()

    set(TRIPLET_SYSTEM_ARCH ${VCPKG_TARGET_ARCHITECTURE})
    include(${SCRIPTS}/cmake/vcpkg_common_definitions.cmake)
    include(${SCRIPTS}/cmake/vcpkg_common_functions.cmake)

    if(DEFINED VCPKG_LOAD_ENVIROMNENT_BATCH)
        vcpkg_load_environment_from_batch(
                BATCH_FILE_PATH ${VCPKG_LOAD_ENVIROMNENT_BATCH}
                ARGUMENTS       ${VCPKG_LOAD_ENVIROMNENT_BATCH_ARGS})
    endif()

    include(${CURRENT_PORT_DIR}/portfile.cmake)
    if(DEFINED PORT)
        include(${SCRIPTS}/build_info.cmake)
    endif()
elseif(CMD MATCHES "^CREATE$")
    file(TO_NATIVE_PATH ${VCPKG_ROOT_DIR} NATIVE_VCPKG_ROOT_DIR)
    file(TO_NATIVE_PATH ${DOWNLOADS} NATIVE_DOWNLOADS)
    set(PORT_PATH "${VCPKG_ROOT_DIR}/ports/${PORT}")
    file(TO_NATIVE_PATH ${PORT_PATH} NATIVE_PORT_PATH)
    set(PORTFILE_PATH "${PORT_PATH}/portfile.cmake")
    file(TO_NATIVE_PATH ${PORTFILE_PATH} NATIVE_PORTFILE_PATH)
    set(MANIFEST_PATH "${PORT_PATH}/vcpkg.json")
    file(TO_NATIVE_PATH ${MANIFEST_PATH} NATIVE_MANIFEST_PATH)

    if(EXISTS "${PORTFILE_PATH}")
        message(FATAL_ERROR "Portfile already exists: '${NATIVE_PORTFILE_PATH}'")
    endif()
    if(NOT FILENAME)
        get_filename_component(FILENAME "${URL}" NAME)
    endif()
    string(REGEX REPLACE "(\\.(zip|gz|tar|tgz|bz2))+\$" "" ROOT_NAME ${FILENAME})

    set(DOWNLOAD_PATH "${DOWNLOADS}/${FILENAME}")
    file(TO_NATIVE_PATH ${DOWNLOAD_PATH} NATIVE_DOWNLOAD_PATH)

    if(EXISTS "${DOWNLOAD_PATH}")
        message(STATUS "Using pre-downloaded: ${NATIVE_DOWNLOAD_PATH}")
        message(STATUS "If this is not desired, delete the file and ${NATIVE_PORT_PATH}")
    else()
        include(vcpkg_download_distfile)
        set(_VCPKG_INTERNAL_NO_HASH_CHECK ON)
        vcpkg_download_distfile(ARCHIVE
            URLS ${URL}
            FILENAME ${FILENAME}
        )
        set(_VCPKG_INTERNAL_NO_HASH_CHECK OFF)
    endif()
    file(SHA512 ${DOWNLOAD_PATH} SHA512)

    file(MAKE_DIRECTORY ${PORT_PATH})
    configure_file(${SCRIPTS}/templates/portfile.in.cmake ${PORTFILE_PATH} @ONLY)
    configure_file(${SCRIPTS}/templates/vcpkg.json.in ${MANIFEST_PATH} @ONLY)

    message(STATUS "Generated portfile: ${NATIVE_PORTFILE_PATH}")
    message(STATUS "Generated manifest: ${NATIVE_MANIFEST_PATH}")
    message(STATUS "To launch an editor for these new files, run")
    message(STATUS "    .\\vcpkg edit ${PORT}")
endif()
