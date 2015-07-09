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
# Load support functions
. ../../lib/functions.sh

PROG=zsh
VER=5.0.7
VERHUMAN=$VER
PKG=shell/zsh
SUMMARY="Z shell"
DESC="Z shell"

DEPENDS_IPS="system/library system/library/math library/pcre"

BUILDARCH=32
CPPFLAGS32="$CPPFLAGS32 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin
	--enable-cap
	--enable-dynamic
	--enable-etcdir=/etc
	--enable-function-subdirs
	--enable-ldflags=-zignore
	--enable-libs=-lnsl
	--enable-maildir-support
	--enable-multibyte
	--enable-pcre
	--with-tcsetpgrp
	--disable-gdbm"

install_zshrc() {
  mkdir -p $DESTDIR/etc
  cp $SRCDIR/files/system-zshrc $DESTDIR/etc/zshrc
  chmod 644 $DESTDIR/etc/zshrc
}
install_license() {
  iconv -f 8859-1 -t utf-8 $TMPDIR/$BUILDDIR/LICENCE > $TMPDIR/$BUILDDIR/LICENSE
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install_zshrc
install_license
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
