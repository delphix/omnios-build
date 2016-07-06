#!/usr/bin/bash

#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright (c) 2016 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=ccache
VER=3.2.5
VERHUMAN=$VER
PKG=developer/ccache
SUMMARY="Compiler Cache"
DESC="Compiler Cache"

BUILD_DEPENDS_IPS=
RUN_DEPENDS_IPS=

PREFIX="/opt/ccache"
BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
	--sysconfdir=/etc
	--includedir=$PREFIX/include
	--bindir=$PREFIX/bin
	--sbindir=$PREFIX/sbin
	--libdir=$PREFIX/lib
	--libexecdir=$PREFIX/libexec
	CFLAGS=-std=gnu99"

save_function make_install make_install_orig
make_install() {
	make_install_orig
	logmsg "Installing etc/ccache.conf"
	logcmd mkdir $DESTDIR/etc || \
	    logerr "--- Failed to mkdir $DESTDIR/etc"
	logcmd cp $TMPDIR/$BUILDDIR/ccache.conf $DESTDIR/etc/ || \
	    logerr "--- Failed to copy ccache.conf"
	pushd $DESTDIR/$PREFIX/bin > /dev/null || \
	    logerr "Cannot change to $DESTDIR/$PREFIX"
	logcmd ln -s ccache gcc || logerr "gcc symlink failed"
	logcmd ln -s ccache g++ || logerr "g++ symlink failed"
	logcmd ln -s ccache cc || logerr "cc symlink failed"
	logcmd ln -s ccache c++ || logerr "c++ symlink failed"
	popd > /dev/null
}

preprep_build() {
	pushd $TMPDIR/$BUILDDIR > /dev/null || \
	    logerr "Cannot change to build directory"
	logcmd ./autogen.sh || logerr "autogen.sh failed"
	popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
preprep_build
prep_build
build
make_isa_stub
make_package
clean_up
