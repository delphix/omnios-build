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

#
# Copyright (c) 2016 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

# Patches are obtained from ftp://ftp.vim.org/pub/vim/patches/7.4/
# To update, append each patch to patches/all-patches and set the
# PATCHLEVEL variable below to match the number of the most recent
# patch, removing any zero padding.

PROG=vim
VER=7.4
PATCHLEVEL=45
PKG=editor/vim
SUMMARY="Vi IMproved"
DESC="$SUMMARY version $VER"

BUILDDIR=${PROG}${VER/./}     # Location of extracted source
BUILDARCH=32

DEPENDS_IPS="system/extended-system-utilities system/library system/library/math"

# We're only shipping 32-bit so forgo isaexec
CONFIGURE_OPTS="
    --bindir=$PREFIX/bin
    --with-features=huge
    --without-x
    --disable-gui
    --disable-gtktest
"
reset_configure_opts

preprep_build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "Cannot change to build directory"
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
    popd > /dev/null
}

# The build doesn't supply a 'vi' symlink so we make one
link_vi() {
    logmsg "Creating symlink for $PREFIX/bin/vi"
    logcmd ln -s vim $DESTDIR$PREFIX/bin/vi
}

# Copy a vimrc so as to set vim in a vi-incompatible manner
copy_vimrc() {
    logmsg "Copying vimrc to /etc/vimrc"
    logcmd mkdir -p $DESTDIR/etc
    logcmd cp $SRCDIR/files/vimrc $DESTDIR/etc/vimrc
}

init
download_source $PROG $PROG $VER
patch_source
preprep_build
prep_build
build
link_vi
copy_vimrc
make_isa_stub
VER=${VER}.${PATCHLEVEL}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
