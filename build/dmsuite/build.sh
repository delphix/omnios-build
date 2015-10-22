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
# Copyright (c) 2014, 2015 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=dmsuite
VER=4.7.2.0
VERHUMAN=$VER
BUILDDIR=dmsuite
PKG=service/dmsuite
SUMMARY="DMSuite"
DESC="DMSuite is a discovery and masking solution by Axis Technology."

BUILD_DEPENDS_IPS=
RUN_DEPENDS_IPS=

init
prep_build

pushd $TMPDIR >/dev/null || logerr "Unable to cd to $TMPDIR."

get_resource dmsuite/dmsuite_$VER.zip || \
    logerr "Unable to get dmsuite/dmsuite_$VER.zip"
unzip -o dmsuite_$VER.zip || logerr "Unable to unzip."

patch_source

logcmd mkdir $DESTDIR/opt/ || logerr "failed to create $DESTDIR/opt/"
logcmd cp -r $BUILDDIR $DESTDIR/opt/dmsuite$VER || logerr "failed to copy"

popd >/dev/null

make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
