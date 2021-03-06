## # vcpkg_acquire_msys
##
## Download and prepare an MSYS2 instance.
##
## ## Usage
## ```cmake
## vcpkg_acquire_msys(<MSYS_ROOT_VAR> [PACKAGES <package>...])
## ```
##
## ## Parameters
## ### MSYS_ROOT_VAR
## An out-variable that will be set to the path to MSYS2.
##
## ### PACKAGES
## A list of packages to acquire in msys.
##
## To ensure a package is available: `vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.15)`
##
## ## Notes
## A call to `vcpkg_acquire_msys` will usually be followed by a call to `bash.exe`:
## ```cmake
## vcpkg_acquire_msys(MSYS_ROOT)
## set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
##
## vcpkg_execute_required_process(
##     COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
##     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
##     LOGNAME build-${TARGET_TRIPLET}-rel
## )
## ```
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
## * [libvpx](https://github.com/Microsoft/vcpkg/blob/master/ports/libvpx/portfile.cmake)

function(vcpkg_acquire_msys PATH_TO_ROOT_OUT)
  set(TOOLPATH ${DOWNLOADS}/tools/msys2)
  cmake_parse_arguments(_am "" "" "PACKAGES" ${ARGN})

  if(NOT CMAKE_HOST_WIN32)
    message(FATAL_ERROR "vcpkg_acquire_msys() can only be used on Windows hosts")
  endif()

  # detect host architecture
  if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
  else()
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
  endif()

  if(_vam_HOST_ARCHITECTURE STREQUAL "AMD64")
    set(TOOLSUBPATH msys64)
    set(URLS
#      "http://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20200602.tar.xz"
#      "https://github.com/msys2/msys2-installer/releases/download/2020-06-02/msys2-base-x86_64-20200602.tar.xz"
#      "https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20200602.tar.xz/download"
      "https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20200720.tar.xz"
      "https://github.com/msys2/msys2-installer/releases/download/2020-07-20/msys2-base-x86_64-20200720.tar.xz"
    )
    set(ARCHIVE "msys2-base-x86_64-20200602.tar.xz")
    set(HASH 1d0841107ded2c7917ebe1810175b940dd9ee9478200d535af0c99b235eb1102659c08cbe0f760e6c1c2a06ecf2f49537c7e0470662a99b72f0f8f0011b5242d)
#    set(HASH ea754c9ea9fc7ae7051c15f97f5ee95dc628bf12af3713f941991a6ab3169f4c23767d132fa6640338a449648998dc4013c6f094f7ce2fe44c61caf276caf8c6)
    set(STAMP "initialized-msys2_64.stamp")
  else()
    set(TOOLSUBPATH msys32)
    set(URLS
      "http://repo.msys2.org/distrib/i686/msys2-base-i686-20200517.tar.xz"
      "https://github.com/msys2/msys2-installer/releases/download/2020-05-17/msys2-base-i686-20200517.tar.xz"
    )
    set(ARCHIVE "msys2-base-i686-20200517.tar.xz")
    set(HASH 74786326c07c1cf2b11440cbd7caf947c2a32ebcc2b5bb362301d12327a2108182f57e98c217487db75bf6f0e3a4577291933e025b9b170e37848ec0b51a134c)
    set(STAMP "initialized-msys2_32.stamp")
  endif()

  set(PATH_TO_ROOT ${TOOLPATH}/${TOOLSUBPATH})

  if(NOT EXISTS "${TOOLPATH}/${STAMP}")

    message(STATUS "Acquiring MSYS2...")
    vcpkg_download_distfile(ARCHIVE_PATH
        URLS ${URLS}
        FILENAME ${ARCHIVE}
        SHA512 ${HASH}
    )

    file(REMOVE_RECURSE ${TOOLPATH}/${TOOLSUBPATH})
    file(MAKE_DIRECTORY ${TOOLPATH})
    _execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;rm -r /etc/pacman.d/gnupg/"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman-key --init;PATH=/usr/bin;pacman-key --populate"#;PATH=/usr/bin;pacman-key --refresh-keys"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Sydd --noconfirm --needed --ask=20 --disable-download-timeout --overwrite '*' pacman"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND taskkill /f /fi "MODULES eq msys-2.0.dll"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syuu --noconfirm --ask=20 --disable-download-timeout --overwrite '*'"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND taskkill /f /fi "MODULES eq msys-2.0.dll"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syuu --noconfirm --ask=20 --disable-download-timeout --overwrite '*'"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND taskkill /f /fi "MODULES eq msys-2.0.dll"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Sydd --noconfirm --needed --ask=20 --disable-download-timeout --overwrite '*' pacman-contrib"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND taskkill /F /IM gpg-agent.exe /fi "memusage gt 2"
      WORKING_DIRECTORY ${TOOLPATH}
    )

    file(WRITE "${TOOLPATH}/${STAMP}" "0")
    message(STATUS "Acquiring MSYS2... OK")
  endif()

  if(_am_PACKAGES)
    message(STATUS "Acquiring MSYS Packages...")
    string(REPLACE ";" " " _am_PACKAGES "${_am_PACKAGES}")
    set(_ENV_ORIGINAL $ENV{PATH})
    set(ENV{PATH} ${PATH_TO_ROOT}/usr/bin)
	
    # Remove database lock
    SET(DB_LOCK_PATH ${PATH_TO_ROOT}/var/lib/pacman/db.lck)
    if (EXISTS "${DB_LOCK_PATH}")
      message(STATUS "${DB_LOCK_PATH} exists --- deleting it")
      file(REMOVE "${DB_LOCK_PATH}")
    endif()
	
#    vcpkg_execute_required_process(
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "rm -r /etc/pacman.d/gnupg/"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )
#    vcpkg_execute_required_process(
#      COMMAND taskkill /f /fi "MODULES eq msys-2.0.dll"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )
#    vcpkg_execute_required_process(
#      ALLOW_IN_DOWNLOAD_MODE
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman-key --init && pacman-key --populate"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )
    vcpkg_execute_required_process(
      COMMAND taskkill /F /IM dirmngr.exe /fi "memusage gt 2"
      WORKING_DIRECTORY ${TOOLPATH}
    )
#    _execute_process(
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "gpgconf --homedir /etc/pacman.d/gnupg --kill all"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )
#    vcpkg_execute_required_process(
#      COMMAND taskkill /f /fi "MODULES eq msys-2.0.dll"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )

    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman -Su --noconfirm --needed --overwrite '*' `pacman -Ssq ${_am_PACKAGES}` "
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman -S --noconfirm --needed --ask=20 --disable-download-timeout --overwrite '*' ${_am_PACKAGES} "
      WORKING_DIRECTORY ${TOOLPATH}
      LOGNAME msys-pacman-${TARGET_TRIPLET}
    )
    vcpkg_execute_required_process(
      COMMAND taskkill /F /IM gpg-agent.exe /fi "memusage gt 2"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    set(ENV{PATH} "${_ENV_ORIGINAL}")

    message(STATUS "Acquiring MSYS Packages... OK")
  endif()

#      vcpkg_execute_required_process(
#          ALLOW_IN_DOWNLOAD_MODE
#          COMMAND TASKKILL /F /IM gpg-agent.exe /fi "memusage gt 2"
#          WORKING_DIRECTORY ${TOOLPATH}
#      )

  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
