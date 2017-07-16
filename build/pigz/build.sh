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
# Copyright (c) 2015, 2017 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=pigz
VER=2.3.3
PKG=compress/pigz
SUMMARY="$PROG - A parallel implementation of gzip for modern multi-processor, multi-core machines"
DESC="$SUMMARY"
DEPENDS_IPS="library/zlib"
BUILD_DEPENDS_IPS="$DEPENDS_IPS"
MAKE="gmake"
LDFLAGS64="-lz -m64"

# pigz doesn't use configure, just make
make_clean() {
    gmake clean
}

configure32() {
    true
}

configure64() {
    true
}

make_prog32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gmake CC=gcc CFLAGS="-O3 -Wall -Wextra -std=c99 -m32" \
	LDFLAGS="-lz -m32" || logerr "gmake failed"
    popd > /dev/null
}

make_prog64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gmake CC=gcc CFLAGS="-O3 -Wall -Wextra -std=c99 -m64" \
	LDFLAGS="-lz -m64" || logerr "gmake failed"
    popd > /dev/null
}

make_install32() {
    logcmd mkdir -p $DESTDIR/usr/bin/i386
    logcmd cp $TMPDIR/$BUILDDIR/pigz $DESTDIR/usr/bin/i386
}

make_install64() {
    logcmd mkdir -p $DESTDIR/usr/bin/amd64
    logcmd cp $TMPDIR/$BUILDDIR/pigz $DESTDIR/usr/bin/amd64
}

copy_man_page() {
    logcmd mkdir -p $DESTDIR/usr/share/man/man1
    logcmd cp $TMPDIR/$BUILDDIR/pigz.1 $DESTDIR/usr/share/man/man1
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
copy_man_page
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
