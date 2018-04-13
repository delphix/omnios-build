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
# Copyright (c) 2018 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh

CC=gcc
CXX=g++

PROG=ruby
VER=2.5.1
VERHUMAN=$VER
PKG=runtime/ruby-25
SUMMARY="Ruby, RubyGems, and Rake"
DESC="$SUMMARY - ${VER}"

BUILD_DEPENDS_IPS="omniti/library/libyaml library/libffi omniti/library/libgdbm"
DEPENDS_IPS="omniti/library/libyaml library/libffi omniti/library/libgdbm"

REMOVE_PREVIOUS=1

MAKE="gmake"

PREFIX="/opt/ruby/$VER"

CFLAGS64="-m64"
LDFLAGS32="-L/opt/omni/lib -R/opt/omni/lib"
LDFLAGS64="-L/opt/omni/lib/amd64 -R/opt/omni/lib/amd64"
CPPFLAGS32="-I/opt/omni/include"
CPPFLAGS64="-I/opt/omni/include/amd64"

SYSCONFDIR=/etc/fluent

#
# We want the following directory structure:
#
#     binaries  => bin/{i386,amd64}/* => binaries
#     arch libs => lib/{arch}/libruby.so* {archlibdir}
#     ruby libs => lib/ruby/2.5.0/*.rb  {rubylibprefix}
#     ruby arch libs => lib/ruby/{i386,amd64}/2.5.0/*.so {rubyarchprefix}
#

CONFIGURE_OPTS="--sysconfdir=${SYSCONFDIR}
    --enable-shared
    --enable-multiarch
    --disable-install-doc
    --enable-dtrace
    --with-rubylibprefix=${PREFIX}/lib/ruby"

CONFIGURE_OPTS_32="--prefix=${PREFIX}
    --build=i386-pc-solaris2.11
    --bindir=${PREFIX}/bin/${ISAPART}
    --with-archlibdir=${PREFIX}/lib/${ISAPART}
    --with-archincludedir=${PREFIX}/include
    --with-rubyarchprefix=${PREFIX}/lib/ruby/${ISAPART}
    --with-rubysitearchprefix=${PREFIX}/lib/ruby/${ISAPART}"

CONFIGURE_OPTS_64="--prefix=${PREFIX}
    --build=x86_64-pc-solaris2.11
    --bindir=${PREFIX}/bin/${ISAPART64}
    --with-archlibdir=${PREFIX}/lib/${ISAPART64}
    --with-archincludedir=${PREFIX}/include/${ISAPART64}
    --with-rubyarchprefix=${PREFIX}/lib/ruby/${ISAPART64}
    --with-rubysitearchprefix=${PREFIX}/lib/ruby/${ISAPART64}"

#
# NOTE:
# Don't do a distclean, it cleans few prebuilt files in the source tarball
# which is essential to build this without using a base ruby (--with-baseruby).
# Hence this override to skip distclean.
#
make_clean() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd $MAKE clean
    popd > /dev/null
}

configure32() {
    logmsg "--- configure (32-bit)"
    CFLAGS="$CFLAGS $CFLAGS32" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS32" \
    LDFLAGS="$LDFLAGS $LDFLAGS32" \
    CC="$CC -m32" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_32 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

configure64() {
    logmsg "--- configure (64-bit)"
    CFLAGS="$CFLAGS $CFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC="$CC -m64" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}


init
download_source $PROG $PROG $VER
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
