
#Setting up single configuration generators
#if(CMAKE_BUILD_TYPE MATCHES "^Debug$")
#Debug build: Put Debug paths before Release paths.
#    list(APPEND CMAKE_PREFIX_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
#    )
#    list(APPEND CMAKE_LIBRARY_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link
#    )
#    list(APPEND CMAKE_FIND_ROOT_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
#    )
#else() 
#Release build: Put Release paths before Debug paths. 
#Debug Paths are required so that CMake generates correct info in autogenerated target files.
#    list(APPEND CMAKE_PREFIX_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET} 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug
#    )
#    list(APPEND CMAKE_LIBRARY_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link
#    )
#    list(APPEND CMAKE_FIND_ROOT_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET} 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug
#    )
#endif()

#Setting up mutli configuration generators
#if(DEFINED CMAKE_CONFIGURATION_TYPES)
#    list(APPEND CMAKE_PREFIX_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
#    )
#    list(APPEND CMAKE_LIBRARY_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link
#    )
#    list(APPEND CMAKE_FIND_ROOT_PATH
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug 
#        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
#    )
    #This paths mean that cmake will ALWAYS find the debug library first if there is no other way to distinguish between release and debug libraries.
    #This fact will be used to correct the library paths in the find_library call! Both paths are still required so that CMake can find both libraries
    #if it can distinguish the release and debug libraries by name!
#endif()

#Setting up CMake search paths
list(APPEND CMAKE_PREFIX_PATH
    ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug 
    ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
)
list(APPEND CMAKE_LIBRARY_PATH
    ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link 
    ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link
)
list(APPEND CMAKE_FIND_ROOT_PATH
    ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug 
    ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
)
#setting up the search paths like this will make sure that vcpkg always finds the debug libraries first. 
#This circumstance will be used to fix the library paths in find_library

#Setting up find_program calls to find all compiled programs (only release versions!)
list(APPEND CMAKE_PROGRAM_PATH ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools)
file(GLOB _VCPKG_TOOLS_DIRS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/*)
foreach(_VCPKG_TOOLS_DIR ${_VCPKG_TOOLS_DIRS})
    if(IS_DIRECTORY ${_VCPKG_TOOLS_DIR})
        list(APPEND CMAKE_PROGRAM_PATH ${_VCPKG_TOOLS_DIR})
    endif()
endforeach()

file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" _programfiles)
set(_PROGRAMFILESX86 "PROGRAMFILES(x86)")
file(TO_CMAKE_PATH "$ENV{${_PROGRAMFILESX86}}" _programfiles_x86)

#VCPKG will ignore default installation paths of OpenSSL on Windows. 
set(CMAKE_SYSTEM_IGNORE_PATH
    "${_programfiles}/OpenSSL"
    "${_programfiles}/OpenSSL-Win32"
    "${_programfiles}/OpenSSL-Win64"
    "${_programfiles}/OpenSSL-Win32/lib/VC"
    "${_programfiles}/OpenSSL-Win64/lib/VC"
    "${_programfiles}/OpenSSL-Win32/lib/VC/static"
    "${_programfiles}/OpenSSL-Win64/lib/VC/static"
    "${_programfiles_x86}/OpenSSL"
    "${_programfiles_x86}/OpenSSL-Win32"
    "${_programfiles_x86}/OpenSSL-Win64"
    "${_programfiles_x86}/OpenSSL-Win32/lib/VC"
    "${_programfiles_x86}/OpenSSL-Win64/lib/VC"
    "${_programfiles_x86}/OpenSSL-Win32/lib/VC/static"
    "${_programfiles_x86}/OpenSSL-Win64/lib/VC/static"
    "C:/OpenSSL/"
    "C:/OpenSSL-Win32/"
    "C:/OpenSSL-Win64/"
    "C:/OpenSSL-Win32/lib/VC"
    "C:/OpenSSL-Win64/lib/VC"
    "C:/OpenSSL-Win32/lib/VC/static"
    "C:/OpenSSL-Win64/lib/VC/static"
)