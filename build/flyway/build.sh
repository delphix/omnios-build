#!/usr/bin/bash
#
# CDDL HEADER START
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
# CDDL HEADER END
#

#
# Copyright (c) 2015 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=flyway
VER=3.2.1
VERHUMAN=$VER
PKG=library/flyway
SUMMARY="Schema management tool"
DESC="Schema management tool"

BUILD_DEPENDS_IPS=
RUN_DEPENDS_IPS=

init
prep_build

pushd $TMPDIR >/dev/null || logerr "Unable to cd to $TMPDIR."

get_resource $PROG/$PROG-$VER.tar.gz || \
    logerr "Unable to get $PROG/$PROG-$VER.tar.gz"
tar zxf $PROG-$VER.tar.gz || logerr "Unable to untar"

logcmd mkdir $DESTDIR/opt/ || logerr "failed to create $DESTDIR/opt/"
logcmd cp -r $PROG-$VER $DESTDIR/opt/$PROG$VER || logerr "failed to copy"

popd >/dev/null

make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
