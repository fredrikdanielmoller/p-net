#********************************************************************
#        _       _         _
#  _ __ | |_  _ | |  __ _ | |__   ___
# | '__|| __|(_)| | / _` || '_ \ / __|
# | |   | |_  _ | || (_| || |_) |\__ \
# |_|    \__|(_)|_| \__,_||_.__/ |___/
#
# www.rt-labs.com
# Copyright 2018 rt-labs AB, Sweden.
#
# This software is dual-licensed under GPLv3 and a commercial
# license. See the file LICENSE.md distributed with this software for
# full license information.
#*******************************************************************/

target_include_directories(profinet
  PRIVATE
  src/ports/rt-kernel
  )

target_sources(profinet
  PRIVATE
  src/ports/rt-kernel/pnal.c
  src/ports/rt-kernel/pnal_eth.c
  src/ports/rt-kernel/pnal_udp.c
  src/ports/rt-kernel/pnal_snmp.c
  src/ports/rt-kernel/mib/mib2_system.c
  src/ports/rt-kernel/mib/lldp-mib.c
  src/ports/rt-kernel/mib/lldp-ext-pno-mib.c
  src/ports/rt-kernel/mib/lldp-ext-dot3-mib.c
  src/ports/rt-kernel/mib/rowindex.c
  src/ports/rt-kernel/dwmac1000.c
  )

target_compile_options(profinet
  PRIVATE
  -Wall
  -Wextra
  -Werror
  -Wno-unused-parameter
  )

target_include_directories(pn_dev
  PRIVATE
  sample_app
  src/ports/rt-kernel
  )

target_sources(pn_dev
  PRIVATE
  sample_app/sampleapp_common.c
  src/ports/rt-kernel/sampleapp_main.c
  )

if (BUILD_TESTING)
  target_sources(pf_test
    PRIVATE
    ${PROFINET_SOURCE_DIR}/src/ports/rt-kernel/pnal.c
    )
  target_include_directories(pf_test
    PRIVATE
    src/ports/rt-kernel
    )
endif()
