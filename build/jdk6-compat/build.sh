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
# Copyright (c) 2016 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=jdk6-compat
VER=26
BUILDDIR=jdk1.6.0
VERHUMAN=$VER
PKG=developer/java/jdk6-compat
SUMMARY="Java Platform 1.6 compatibility VM and core class libraries"
DESC="Java Platform 1.6 compatability virtual machine and core class libaries"

BUILD_DEPENDS_IPS="pkg:/system/library pkg:/system/library/math pkg:/shell/bash pkg:/library/unixodbc pkg:/archiver/gnu-tar"
RUN_DEPENDS_IPS=

init
prep_build

pushd $TMPDIR >/dev/null || logerr "Unable to cd to $TMPDIR."

get_resource jdk6-compat/jdk6u$VER-compat.tar.gz || \
    logerr "jdk6u$VER-compat.tar.gz not found"

mkdir $DESTDIR/opt || logerr "Unable to mkdir $DESTDIR/opt."

#untar the package and install
tar -zxf jdk6u$VER-compat.tar.gz -C $DESTDIR/opt || \
    logger "jdk6u$VER-compat untar failed."

popd >/dev/null

make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
