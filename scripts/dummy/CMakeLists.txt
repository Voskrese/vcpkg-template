#Dummy CMakeLists.txt to extract costum toolset compilers & linkers within Visual Studio

cmake_minimum_required(VERSION 3.3)
FILE(READ "${Project_BINARY_DIR}/CMakeFiles/CMakeOutput.log" MAKE_COMPILE_TEST_FILE)
message(STATUS "Trying to figure out compiler and linker")
STRING(REGEX MATCH "[^\n]+\.exe [^\n]+CMakeCCompilerId.c" VCPKG_C_COMPILER ${MAKE_COMPILE_TEST_FILE})
#MESSAGE(STATUS "C:${VCPKG_C_COMPILER}")
STRING(REGEX MATCH "[^\n]+\.exe" VCPKG_C_COMPILER ${VCPKG_C_COMPILER})
STRING(REGEX MATCH "[^\n]+\.exe [^\n]+CMakeCXXCompilerId.c" VCPKG_CXX_COMPILER ${MAKE_COMPILE_TEST_FILE})
#MESSAGE(STATUS "CXX:${VCPKG_CXX_COMPILER}")
STRING(REGEX MATCH "[^\n]+\.exe" VCPKG_CXX_COMPILER ${VCPKG_CXX_COMPILER}) 
STRING(REGEX MATCH "Link:\n  ([A-Z]:[A-Za-z0-9_ |\\|\.|\(\)|-]+)" VCPKG_LINKER ${MAKE_COMPILE_TEST_FILE})
#MESSAGE(STATUS "L:${VCPKG_LINKER}")
STRING(REGEX MATCH "[^\n]+\.exe" VCPKG_LINKER ${VCPKG_LINKER}) 

SET(DUMMY_OUT "compiler_linker_info.txt")
#MESSAGE(STATUS "C:${VCPKG_C_COMPILER}")
#MESSAGE(STATUS "CXX:${VCPKG_CXX_COMPILER}")
#MESSAGE(STATUS "L:${VCPKG_LINKER}")

STRING(STRIP ${VCPKG_C_COMPILER} VCPKG_C_COMPILER)
STRING(STRIP ${VCPKG_CXX_COMPILER} VCPKG_CXX_COMPILER)
STRING(STRIP ${VCPKG_LINKER} VCPKG_LINKER)
FILE(WRITE "${DUMMY_OUT}" "VCPKG_C_COMPILER=${VCPKG_C_COMPILER}\n")
FILE(APPEND "${DUMMY_OUT}" "VCPKG_CXX_COMPILER=${VCPKG_CXX_COMPILER}\n")
FILE(APPEND "${DUMMY_OUT}" "VCPKG_LINKER=${VCPKG_LINKER}\n")

# Data to check if we need to regenerate the dummy
FILE(APPEND "${DUMMY_OUT}" "VCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}\n")
FILE(APPEND "${DUMMY_OUT}" "VCPKG_VISUAL_STUDIO_PATH=${VCPKG_VISUAL_STUDIO_PATH}\n")
FILE(APPEND "${DUMMY_OUT}" "VCPKG_CMAKE_VS_GENERATOR=${VCPKG_CMAKE_VS_GENERATOR}\n")
FILE(APPEND "${DUMMY_OUT}" "TARGET_TRIPLET=${TARGET_TRIPLET}\n")
