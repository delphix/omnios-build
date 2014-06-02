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

PROG=xen-tools
VER=4.4.0
VERHUMAN=$VER
PKG=system/virtualization/xen-tools
SUMMARY="Xen tools"
DESC="A collection of tools to retrieve guest specific metadata from within a Xen guest."
BUILDDIR=xen-$VER
BUILDARCH=32

export AS86=/bin/true
export LD86=/bin/true
export BCC=/bin/true
export IASL=/bin/true

CONFIGURE_OPTS="--disable-xen --disable-kernels --disable-doc --disable-stubdom"

TOOLS_DIR=$TMPDIR/$BUILDDIR/tools

make_prog() {
    (logcmd cd $TOOLS_DIR &&
	    logcmd gmake -C include &&
            logcmd gmake -C misc xen-detect &&
            logcmd gmake -C xenstore clients) ||
            logerr "--- make_prog failed"
}

make_install() {
    (logcmd cd $TOOLS_DIR &&
	    logcmd gmake DESTDIR=${DESTDIR} -C misc install-xen-detect &&
	    logcmd gmake DESTDIR=${DESTDIR} -C xenstore install-clients) ||
	    logerr "--- make_install failed"
}

init
download_source ${PROG%-*} ${PROG%-*} $VER
patch_source
prep_build
build
make_package
clean_up
