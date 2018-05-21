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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Copyright (c) 2018 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh

PROG=postgresql
VER=10.4
VERHUMAN=$VER
PKG=omniti/database/postgresql-104
SUMMARY="$PROG - Open Source Database System"
DESC="$SUMMARY"

DEPENDS_IPS="omniti/database/postgresql/common"

DOWNLOADDIR=postgres
BUILDARCH=64
PREFIX=/opt/pgsql${VER//./}
RPATH="../lib"

# if this is being called from the 5.1 delphix script, replace some settings
if [[ "$DLPX51_POSTGRES_PREFIX" ]]; then
    PREFIX=$DLPX51_POSTGRES_PREFIX
fi

if [[ "$DLPX51_POSTGRES_PKG" ]]; then
    PKG=$DLPX51_POSTGRES_PKG
fi

unset DLPX51_POSTGRES_PKG
unset DLPX51_POSTGRES_PREFIX

reset_configure_opts

CFLAGS="-O3"

CONFIGURE_OPTS="--enable-thread-safety
    --enable-debug
    --with-openssl
    --with-libxml
    --with-xslt
    --with-readline
    --with-uuid=e2fs
    --prefix=$PREFIX"

# We don't want the default settings for CONFIGURE_OPTS_64
CONFIGURE_OPTS_64="--enable-dtrace DTRACEFLAGS=\"-64\""
LDFLAGS="-Wl,-rpath='$RPATH'"

init
download_source $DOWNLOADDIR $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
