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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Copyright (c) 2016, 2017 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh

PROG=pg_partman
VER=3.0.2
VERHUMAN=$VER
PKG=omniti/database/postgresql-945/pg_partman
SUMMARY="PostgreSQL Partition Management Extention"
DESC="$SUMMARY"

#
# The build depends on being able to run pg_config so that it can discover
# where to install itself.
#
PATH=$PATH:/opt/pgsql945/bin

BUILD_DEPENDS_IPS=omniti/database/postgresql-945
RUN_DEPENDS_IPS=omniti/database/postgresql-945

build() {
    pushd $TMPDIR/$BUILDDIR >/dev/null
    make_clean
    make_prog32
    make_install32
    popd > /dev/null
}

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
