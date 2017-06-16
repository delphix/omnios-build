#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=protobuf-3
VER=3.3.0
VERHUMAN=$VER
PKG=omniti/library/protobuf-3

SUMMARY="Protocol Buffers - Google's data interchange format (v3.3.0)"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS=
RUN_DEPENDS_IPS=

CONFIGURE_OPTS="
    --program-suffix=-$VER
    --prefix=/usr/local/$PROG
    --exec-prefix=/usr/local/$PROG
    --oldincludedir=/usr/local/$PROG/include
    --includedir=/usr/local/$PROG/include
    --libdir=/usr/local/$PROG/lib
"
reset_configure_opts

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
