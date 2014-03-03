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
# Copyright (c) 2014 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=mongodb
VER=2.4.9
VERHUMAN=$VER   # Human-readable version
BUILDDIR=mongodb-sunos5-x86_64-$VER
PKG=database/mongodb
SUMMARY="Mongo Database"
DESC="MongoDB is a distributed object store built for easy administration"

BUILD_DEPENDS_IPS=
RUN_DEPENDS_IPS=

init
prep_build

pushd $TMPDIR >/dev/null || logerr "Unable to cd to $TMPDIR."

get_resource mongodb/mongodb-$VER.tar.gz || \
    logerr "Unable to get mongodb/mongodb-$VER.tar.gz"
tar zxf mongodb-$VER.tar.gz || logerr "Unable to untar."

mkdir $DESTDIR/usr/
cp -r $BUILDDIR/bin $DESTDIR/usr/

popd >/dev/null

make_package
clean_up
